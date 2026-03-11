import Foundation

struct Profile: Codable, Identifiable {
    let id: UUID
    let username: String
    let displayName: String?
    let avatarURL: String?
    let createdAt: Date
}
