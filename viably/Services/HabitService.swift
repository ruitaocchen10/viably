import Foundation
import Supabase

struct HabitService {
    static func fetchActive(for userID: UUID) async throws -> [Habit] {
        try await supabase
            .from("habits")
            .select()
            .eq("user_id", value: userID)
            .eq("is_active", value: true)
            .order("created_at", ascending: true)
            .execute()
            .value
    }

    static func create(_ habit: Habit) async throws -> Habit {
        try await supabase
            .from("habits")
            .insert(habit)
            .single()
            .execute()
            .value
    }

    static func fetchAll(for userID: UUID) async throws -> [Habit] {
        try await supabase
            .from("habits")
            .select()
            .eq("user_id", value: userID)
            .order("created_at", ascending: true)
            .execute()
            .value
    }

    static func setActive(habitID: UUID, isActive: Bool) async throws {
        try await supabase
            .from("habits")
            .update(["is_active": isActive])
            .eq("id", value: habitID)
            .execute()
    }

    static func updateStreak(habitID: UUID, newStreak: Int) async throws {
        try await supabase
            .from("habits")
            .update(["current_streak": newStreak])
            .eq("id", value: habitID)
            .execute()
    }
}
