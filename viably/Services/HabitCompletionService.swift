import Foundation
import Supabase

struct HabitCompletionService {
    static func fetchCompletions(for userID: UUID, on date: Date) async throws -> [HabitCompletion] {
        try await supabase
            .from("habit_completions")
            .select()
            .eq("user_id", value: userID)
            .eq("completed_date", value: isoDateString(from: date))
            .execute()
            .value
    }

    static func fetchCompletion(for habitID: UUID, on date: Date) async throws -> HabitCompletion? {
        let results: [HabitCompletion] = try await supabase
            .from("habit_completions")
            .select()
            .eq("habit_id", value: habitID)
            .eq("completed_date", value: isoDateString(from: date))
            .execute()
            .value
        return results.first
    }

    static func complete(habitID: UUID, userID: UUID, on date: Date) async throws {
        let payload = InsertPayload(
            habitID: habitID,
            userID: userID,
            completedDate: isoDateString(from: date)
        )
        try await supabase
            .from("habit_completions")
            .insert(payload)
            .execute()
    }

    private struct InsertPayload: Encodable {
        let habitID: UUID
        let userID: UUID
        let completedDate: String

        enum CodingKeys: String, CodingKey {
            case habitID = "habit_id"
            case userID = "user_id"
            case completedDate = "completed_date"
        }
    }

    static func uncomplete(habitID: UUID, on date: Date) async throws {
        try await supabase
            .from("habit_completions")
            .delete()
            .eq("habit_id", value: habitID)
            .eq("completed_date", value: isoDateString(from: date))
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
