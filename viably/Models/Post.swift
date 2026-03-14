import Foundation

struct Post: Codable, Identifiable {
    let id: UUID
    let userID: UUID
    let scoreDate: Date
    let score: Int
    let caption: String?
    let createdAt: Date

    // Populated client-side after fetching — not in DB columns
    var profile: Profile? = nil
    var completedHabits: [PostCompletedHabit] = []
    var hypeCount: Int = 0
    var didHype: Bool = false

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case scoreDate = "score_date"
        case score
        case caption
        case createdAt = "created_at"
    }
}
