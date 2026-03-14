import Foundation

struct PostCompletedHabit: Codable, Identifiable {
    let id: UUID
    let postID: UUID
    let habitID: UUID
    let habitName: String
    let habitIcon: String?

    enum CodingKeys: String, CodingKey {
        case id
        case postID = "post_id"
        case habitID = "habit_id"
        case habitName = "habit_name"
        case habitIcon = "habit_icon"
    }
}
