import Foundation
import Supabase

struct DailyScoreService {
    static func fetchToday(for userID: UUID) async throws -> DailyScore? {
        let results: [DailyScore] = try await supabase
            .from("daily_scores")
            .select()
            .eq("user_id", value: userID)
            .eq("score_date", value: isoDateString(from: .now))
            .execute()
            .value
        return results.first
    }

    static func upsertToday(userID: UUID, score: Int, maxScore: Int, isViableDay: Bool) async throws {
        let payload = UpsertPayload(
            userID: userID,
            scoreDate: isoDateString(from: .now),
            score: score,
            maxScore: maxScore,
            isViableDay: isViableDay
        )
        try await supabase
            .from("daily_scores")
            .upsert(payload, onConflict: "user_id,score_date")
            .execute()
    }

    private struct UpsertPayload: Encodable {
        let userID: UUID
        let scoreDate: String
        let score: Int
        let maxScore: Int
        let isViableDay: Bool

        enum CodingKeys: String, CodingKey {
            case userID = "user_id"
            case scoreDate = "score_date"
            case score
            case maxScore = "max_score"
            case isViableDay = "is_viable_day"
        }
    }

    private static func isoDateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        return formatter.string(from: date)
    }
}
