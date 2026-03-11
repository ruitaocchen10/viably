import Foundation

struct Habit: Codable, Identifiable {
    let id: UUID
    let userID: UUID
    var name: String
    var icon: String?
    var isMVD: Bool
    var isActive: Bool
    var currentStreak: Int
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name, icon
        case userID = "user_id"
        case isMVD = "is_mvd"
        case isActive = "is_active"
        case currentStreak = "current_streak"
        case createdAt = "created_at"
    }
}
