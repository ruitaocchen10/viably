import Foundation

struct DailyScore: Codable, Identifiable {
    let id: UUID
    let userID: UUID
    let scoreDate: Date
    var score: Int
    var maxScore: Int
    var isViableDay: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, score
        case userID = "user_id"
        case scoreDate = "score_date"
        case maxScore = "max_score"
        case isViableDay = "is_viable_day"
        case createdAt = "created_at"
    }
}
