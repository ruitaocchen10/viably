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

    func createHabit(name: String, icon: String?, isMVD: Bool) async {
        let habit = Habit(
            id: UUID(),
            userID: userID,
            name: name,
            icon: icon,
            description: nil,
            isMVD: isMVD,
            isActive: true,
            currentStreak: 0,
            createdAt: .now
        )
        do {
            let created = try await HabitService.create(habit)
            habits.append(created)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
