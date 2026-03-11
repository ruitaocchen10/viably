import Foundation

struct Profile: Codable, Identifiable {
    let id: UUID
    let username: String
    let displayName: String?
    let avatarURL: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case displayName = "display_name"
        case avatarURL = "avatar_url"
        case createdAt = "created_at"
    }
}
