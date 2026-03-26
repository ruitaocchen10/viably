import Foundation
import Supabase

struct ModerationService {

    // MARK: - Block

    static func blockUser(blockerID: UUID, blockedID: UUID) async throws {
        struct Payload: Encodable {
            let blocker_id: UUID
            let blocked_id: UUID
        }
        try await supabase
            .from("blocks")
            .upsert(Payload(blocker_id: blockerID, blocked_id: blockedID),
                    onConflict: "blocker_id,blocked_id")
            .execute()
    }

    static func fetchBlockedUserIDs(for userID: UUID) async throws -> Set<UUID> {
        struct BlockedRow: Decodable {
            let blocked_id: UUID
        }
        let rows: [BlockedRow] = try await supabase
            .from("blocks")
            .select("blocked_id")
            .eq("blocker_id", value: userID)
            .execute()
            .value
        return Set(rows.map { $0.blocked_id })
    }

    // MARK: - Report

    static func reportPost(reporterID: UUID, postID: UUID, postUserID: UUID, reason: String) async throws {
        try await supabase
            .from("reports")
            .insert(ReportPayload(reporter_id: reporterID, reported_user_id: postUserID,
                                  content_type: "post", content_id: postID, reason: reason))
            .execute()
    }

    static func reportReply(reporterID: UUID, replyID: UUID, replyUserID: UUID, reason: String) async throws {
        try await supabase
            .from("reports")
            .insert(ReportPayload(reporter_id: reporterID, reported_user_id: replyUserID,
                                  content_type: "reply", content_id: replyID, reason: reason))
            .execute()
    }
}

// MARK: - Private helpers

private struct ReportPayload: Encodable {
    let reporter_id: UUID
    let reported_user_id: UUID
    let content_type: String
    let content_id: UUID
    let reason: String
}
