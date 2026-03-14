import Foundation
import Supabase

struct FriendService {

    static func sendRequest(from requesterID: UUID, to addresseeID: UUID) async throws {
        struct Payload: Encodable {
            let requester_id: UUID
            let addressee_id: UUID
        }
        try await supabase
            .from("friendships")
            .insert(Payload(requester_id: requesterID, addressee_id: addresseeID))
            .execute()
    }

    static func acceptRequest(friendshipID: UUID) async throws {
        try await supabase
            .from("friendships")
            .update(["status": "accepted"])
            .eq("id", value: friendshipID)
            .execute()
    }

    static func removeFriend(friendshipID: UUID) async throws {
        try await supabase
            .from("friendships")
            .delete()
            .eq("id", value: friendshipID)
            .execute()
    }

    static func fetchFriends(userID: UUID) async throws -> [Friendship] {
        try await supabase
            .from("friendships")
            .select()
            .eq("status", value: "accepted")
            .or("requester_id.eq.\(userID.uuidString.lowercased()),addressee_id.eq.\(userID.uuidString.lowercased())")
            .execute()
            .value
    }

    static func fetchPendingRequests(userID: UUID) async throws -> [Friendship] {
        try await supabase
            .from("friendships")
            .select()
            .eq("status", value: "pending")
            .eq("addressee_id", value: userID)
            .execute()
            .value
    }
}
