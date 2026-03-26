import Foundation
import Combine
import Supabase

@MainActor
final class SocialFeedViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    let userID: UUID

    init() {
        guard let id = supabase.auth.currentUser?.id else {
            preconditionFailure("SocialFeedViewModel initialized without authenticated user")
        }
        self.userID = id
    }

    func loadFeed() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            async let fetchedPosts = PostService.fetchFeed(for: userID)
            async let blockedIDs = ModerationService.fetchBlockedUserIDs(for: userID)
            let (allPosts, blocked) = try await (fetchedPosts, blockedIDs)
            posts = allPosts.filter { !blocked.contains($0.userID) }
        } catch is CancellationError {
            // Task was cancelled by refreshable — not an error
        } catch let urlError as URLError where urlError.code == .cancelled {
            // URLSession cancelled the in-flight request — not an error
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refresh() async {
        await loadFeed()
    }

    func incrementReplyCount(for postID: UUID) {
        guard let idx = posts.firstIndex(where: { $0.id == postID }) else { return }
        posts[idx].replyCount += 1
    }

    func blockUser(_ blockedID: UUID) async {
        do {
            try await ModerationService.blockUser(blockerID: userID, blockedID: blockedID)
            posts.removeAll { $0.userID == blockedID }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func removePostsFromUser(_ id: UUID) {
        posts.removeAll { $0.userID == id }
    }

    func toggleHype(post: Post) async {
        guard let idx = posts.firstIndex(where: { $0.id == post.id }) else { return }

        // Optimistic update
        let wasHyped = posts[idx].didHype
        posts[idx].didHype = !wasHyped
        posts[idx].hypeCount += wasHyped ? -1 : 1

        do {
            if wasHyped {
                try await HypeService.unhype(userID: userID, postID: post.id)
            } else {
                try await HypeService.hype(userID: userID, postID: post.id)
            }
        } catch {
            // Revert optimistic update
            if let revertIdx = posts.firstIndex(where: { $0.id == post.id }) {
                posts[revertIdx].didHype = wasHyped
                posts[revertIdx].hypeCount += wasHyped ? 1 : -1
            }
            errorMessage = error.localizedDescription
        }
    }
}
