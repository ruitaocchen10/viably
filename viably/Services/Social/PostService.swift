import Foundation
import Supabase

struct PostService {

    // MARK: - Feed

    static func fetchFeed(for userID: UUID) async throws -> [Post] {
        // 1. Get accepted friendships
        let friendships: [Friendship] = try await supabase
            .from("friendships")
            .select()
            .eq("status", value: "accepted")
            .or("requester_id.eq.\(userID.uuidString.lowercased()),addressee_id.eq.\(userID.uuidString.lowercased())")
            .execute()
            .value

        let friendIDs = friendships.map { f -> UUID in
            f.requesterID == userID ? f.addresseeID : f.requesterID
        }

        guard !friendIDs.isEmpty else { return [] }

        // 2. Fetch posts from friends (most recent 50)
        var rawPosts: [Post] = try await supabase
            .from("posts")
            .select()
            .in("user_id", values: friendIDs)
            .order("created_at", ascending: false)
            .limit(50)
            .execute()
            .value

        guard !rawPosts.isEmpty else { return [] }

        let postIDs = rawPosts.map { $0.id }
        let postUserIDs = Array(Set(rawPosts.map { $0.userID }))

        // 3. Fetch profiles (graceful failure — cards show placeholder on error)
        let profiles: [Profile] = (try? await supabase
            .from("profiles")
            .select()
            .in("id", values: postUserIDs)
            .execute()
            .value) ?? []
        let profileByID = Dictionary(uniqueKeysWithValues: profiles.map { ($0.id, $0) })

        // 4. Fetch completed habits for these posts
        let habits: [PostCompletedHabit] = (try? await supabase
            .from("post_completed_habits")
            .select()
            .in("post_id", values: postIDs)
            .execute()
            .value) ?? []
        var habitsByPostID: [UUID: [PostCompletedHabit]] = [:]
        for habit in habits {
            habitsByPostID[habit.postID, default: []].append(habit)
        }

        // 5. Fetch hypes to get counts and current-user flags
        let hypes: [HypeRecord] = (try? await supabase
            .from("hypes")
            .select()
            .in("post_id", values: postIDs)
            .execute()
            .value) ?? []
        var hypeCountByPostID: [UUID: Int] = [:]
        var myHypedPostIDs: Set<UUID> = []
        for hype in hypes {
            hypeCountByPostID[hype.postID, default: 0] += 1
            if hype.userID == userID {
                myHypedPostIDs.insert(hype.postID)
            }
        }

        // 6. Enrich posts with joined data
        for i in rawPosts.indices {
            let post = rawPosts[i]
            rawPosts[i].profile = profileByID[post.userID]
            rawPosts[i].completedHabits = habitsByPostID[post.id] ?? []
            rawPosts[i].hypeCount = hypeCountByPostID[post.id] ?? 0
            rawPosts[i].didHype = myHypedPostIDs.contains(post.id)
        }

        return rawPosts
    }

    // MARK: - Create / Upsert

    @discardableResult
    static func createPost(
        userID: UUID,
        score: Int,
        caption: String?,
        habits: [Habit]
    ) async throws -> Post {
        struct PostPayload: Encodable {
            let user_id: UUID
            let score_date: String
            let score: Int
            let caption: String?
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = .current
        let todayString = dateFormatter.string(from: .now)

        let post: Post = try await supabase
            .from("posts")
            .upsert(
                PostPayload(user_id: userID, score_date: todayString, score: score, caption: caption),
                onConflict: "user_id,score_date"
            )
            .single()
            .execute()
            .value

        // Replace habit snapshot for this post
        try await supabase
            .from("post_completed_habits")
            .delete()
            .eq("post_id", value: post.id)
            .execute()

        struct HabitPayload: Encodable {
            let post_id: UUID
            let habit_id: UUID
            let habit_name: String
            let habit_icon: String?
        }

        let habitPayloads = habits.map { habit in
            HabitPayload(
                post_id: post.id,
                habit_id: habit.id,
                habit_name: habit.name,
                habit_icon: habit.icon
            )
        }

        if !habitPayloads.isEmpty {
            try await supabase
                .from("post_completed_habits")
                .insert(habitPayloads)
                .execute()
        }

        return post
    }

    // MARK: - Fetch My Post

    static func fetchMyPost(userID: UUID) async throws -> Post? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = .current
        let todayString = dateFormatter.string(from: .now)

        let posts: [Post] = try await supabase
            .from("posts")
            .select()
            .eq("user_id", value: userID)
            .eq("score_date", value: todayString)
            .limit(1)
            .execute()
            .value
        return posts.first
    }

    // MARK: - Delete

    static func deletePost(_ postID: UUID) async throws {
        try await supabase
            .from("posts")
            .delete()
            .eq("id", value: postID)
            .execute()
    }
}

// MARK: - Internal type for hype decoding

struct HypeRecord: Codable {
    let postID: UUID
    let userID: UUID

    enum CodingKeys: String, CodingKey {
        case postID = "post_id"
        case userID = "user_id"
    }
}
