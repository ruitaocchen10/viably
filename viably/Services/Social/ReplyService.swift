import Foundation
import Supabase

struct ReplyService {

    static func fetchReplies(postID: UUID) async throws -> [Reply] {
        try await supabase
            .from("replies")
            .select()
            .eq("post_id", value: postID)
            .order("created_at", ascending: true)
            .execute()
            .value
    }

    @discardableResult
    static func createReply(userID: UUID, postID: UUID, content: String) async throws -> Reply {
        struct Payload: Encodable {
            let post_id: UUID
            let user_id: UUID
            let content: String
        }
        return try await supabase
            .from("replies")
            .insert(Payload(post_id: postID, user_id: userID, content: content))
            .single()
            .execute()
            .value
    }

    static func deleteReply(_ replyID: UUID) async throws {
        try await supabase
            .from("replies")
            .delete()
            .eq("id", value: replyID)
            .execute()
    }
}
