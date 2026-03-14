import Foundation
import Supabase

struct HypeService {

    static func hype(userID: UUID, postID: UUID) async throws {
        struct Payload: Encodable {
            let post_id: UUID
            let user_id: UUID
        }
        try await supabase
            .from("hypes")
            .upsert(
                Payload(post_id: postID, user_id: userID),
                onConflict: "post_id,user_id"
            )
            .execute()
    }

    static func unhype(userID: UUID, postID: UUID) async throws {
        try await supabase
            .from("hypes")
            .delete()
            .eq("post_id", value: postID)
            .eq("user_id", value: userID)
            .execute()
    }

    static func fetchCount(postID: UUID) async throws -> Int {
        let hypes: [HypeRecord] = try await supabase
            .from("hypes")
            .select()
            .eq("post_id", value: postID)
            .execute()
            .value
        return hypes.count
    }

    static func didHype(userID: UUID, postID: UUID) async throws -> Bool {
        let hypes: [HypeRecord] = try await supabase
            .from("hypes")
            .select()
            .eq("post_id", value: postID)
            .eq("user_id", value: userID)
            .limit(1)
            .execute()
            .value
        return !hypes.isEmpty
    }
}
