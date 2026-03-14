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

    @discardableResult
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

    static func setActive(habitID: UUID, isActive: Bool, pausedAt: Date?) async throws {
        struct Payload: Encodable {
            let isActive: Bool
            let pausedAt: Date?
            enum CodingKeys: String, CodingKey {
                case isActive = "is_active"
                case pausedAt = "paused_at"
            }
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(isActive, forKey: .isActive)
                try container.encode(pausedAt, forKey: .pausedAt) // sends null, not omitted
            }
        }
        try await supabase
            .from("habits")
            .update(Payload(isActive: isActive, pausedAt: pausedAt))
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

    static func delete(habitID: UUID) async throws {
        try await supabase
            .from("habits")
            .delete()
            .eq("id", value: habitID)
            .execute()
    }

    static func update(habitID: UUID, name: String, icon: String?, description: String?, isMVD: Bool) async throws -> Habit {
        struct Payload: Encodable {
            let name: String
            let icon: String?
            let description: String?
            let isMVD: Bool

            enum CodingKeys: String, CodingKey {
                case name, icon, description
                case isMVD = "is_mvd"
            }
        }
        return try await supabase
            .from("habits")
            .update(Payload(name: name, icon: icon, description: description, isMVD: isMVD))
            .eq("id", value: habitID)
            .single()
            .execute()
            .value
    }
}
