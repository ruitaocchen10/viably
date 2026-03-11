import Foundation

struct HabitCompletion: Codable, Identifiable {
    let id: UUID
    let habitID: UUID
    let userID: UUID
    let completedDate: Date
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case habitID = "habit_id"
        case userID = "user_id"
        case completedDate = "completed_date"
        case createdAt = "created_at"
    }
}
