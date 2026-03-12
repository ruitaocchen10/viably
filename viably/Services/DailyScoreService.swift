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
        let payload: [String: AnyJSON] = [
            "user_id": .string(userID.uuidString),
            "score_date": .string(isoDateString(from: .now)),
            "score": .double(Double(score)),
            "max_score": .double(Double(maxScore)),
            "is_viable_day": .bool(isViableDay)
        ]
        try await supabase
            .from("daily_scores")
            .upsert(payload, onConflict: "user_id,score_date")
            .execute()
    }

    private static func isoDateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        return formatter.string(from: date)
    }
}
