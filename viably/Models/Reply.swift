import Foundation

struct Reply: Codable, Identifiable {
    let id: UUID
    let postID: UUID
    let userID: UUID
    let content: String
    let createdAt: Date

    var profile: Profile? = nil

    enum CodingKeys: String, CodingKey {
        case id
        case postID = "post_id"
        case userID = "user_id"
        case content
        case createdAt = "created_at"
    }
}
