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
        guard let id = supabase.auth.currentUser?.id else {
            preconditionFailure("ViewModel initialized without authenticated user")
        }
        self.userID = id
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

    func setActive(id: UUID, isActive: Bool) async {
        do {
            if isActive {
                let pausedAt = habits.first(where: { $0.id == id })?.pausedAt
                let sameDay = pausedAt.map { Calendar.current.isDateInToday($0) } ?? true
                try await HabitService.setActive(habitID: id, isActive: true, pausedAt: nil)
                if !sameDay {
                    try await HabitService.updateStreak(habitID: id, newStreak: 0)
                }
                if let idx = habits.firstIndex(where: { $0.id == id }) {
                    habits[idx].isActive = true
                    habits[idx].pausedAt = nil
                    if !sameDay { habits[idx].currentStreak = 0 }
                }
            } else {
                let now = Date.now
                try await HabitService.setActive(habitID: id, isActive: false, pausedAt: now)
                if let idx = habits.firstIndex(where: { $0.id == id }) {
                    habits[idx].isActive = false
                    habits[idx].pausedAt = now
                }
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
