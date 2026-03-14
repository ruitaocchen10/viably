import Foundation

struct Friendship: Codable, Identifiable {
    let id: UUID
    let requesterID: UUID
    let addresseeID: UUID
    let status: String   // "pending" | "accepted"
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case requesterID = "requester_id"
        case addresseeID = "addressee_id"
        case status
        case createdAt = "created_at"
    }
}
