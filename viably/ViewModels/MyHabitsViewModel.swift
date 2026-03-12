import Foundation
import Supabase
import Combine

@MainActor
final class MyHabitsViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    var mvdHabits: [Habit] { habits.filter { $0.isMVD && $0.isActive } }
    var otherHabits: [Habit] { habits.filter { !$0.isMVD && $0.isActive } }
    var inactiveHabits: [Habit] { habits.filter { !$0.isActive } }

    private let userID: UUID

    init() {
        self.userID = supabase.auth.currentUser?.id ?? UUID()
    }

    func loadHabits() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            habits = try await HabitService.fetchAll(for: userID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteHabit(id: UUID) async {
        do {
            try await HabitService.delete(habitID: id)
            habits.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateHabit(id: UUID, name: String, icon: String?, description: String?, isMVD: Bool) async {
        do {
            let updated = try await HabitService.update(habitID: id, name: name, icon: icon, description: description, isMVD: isMVD)
            if let idx = habits.firstIndex(where: { $0.id == id }) {
                habits[idx] = updated
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createHabit(name: String, icon: String?, description: String? = nil, isMVD: Bool) async {
        let habit = Habit(
            id: UUID(),
            userID: userID,
            name: name,
            icon: icon,
            description: description,
            isMVD: isMVD,
            isActive: true,
            currentStreak: 0,
            createdAt: .now
        )
        do {
            try await HabitService.create(habit)
            await loadHabits()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
