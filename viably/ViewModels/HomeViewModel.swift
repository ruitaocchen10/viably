import Foundation
import Combine
import Supabase

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var completedHabitIDs: Set<UUID> = []
    @Published var todayScore: DailyScore? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    var scoreValue: Int { todayScore?.score ?? 0 }
    var maxScoreValue: Int { todayScore?.maxScore ?? 0 }
    var isViableDay: Bool { todayScore?.isViableDay ?? false }
    var progressFraction: Double {
        guard maxScoreValue > 0 else { return 0 }
        return Double(scoreValue) / Double(maxScoreValue)
    }
    var mvdHabitsRemaining: Int {
        habits.filter { $0.isMVD && !completedHabitIDs.contains($0.id) }.count
    }
    var userName: String {
        if case .string(let name) = supabase.auth.currentUser?.userMetadata["full_name"] {
            return name.components(separatedBy: " ").first ?? name
        }
        return "there"
    }

    private let userID: UUID

    init() {
        guard let id = supabase.auth.currentUser?.id else {
            preconditionFailure("ViewModel initialized without authenticated user")
        }
        self.userID = id
        Task { await loadAll() }
    }

    func loadAll() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            async let habitsResult = HabitService.fetchActive(for: userID)
            async let completionsResult = HabitCompletionService.fetchCompletions(for: userID, on: .now)
            async let scoreResult = DailyScoreService.fetchToday(for: userID)

            let (fetchedHabits, fetchedCompletions, fetchedScore) = try await (habitsResult, completionsResult, scoreResult)

            habits = fetchedHabits
            completedHabitIDs = Set(fetchedCompletions.map { $0.habitID })
            todayScore = fetchedScore

            let (computedScore, computedMax, computedViable) = recalculateScore()
            try await DailyScoreService.upsertToday(
                userID: userID,
                score: computedScore,
                maxScore: computedMax,
                isViableDay: computedViable
            )
            if var s = fetchedScore {
                s.score = computedScore
                s.maxScore = computedMax
                s.isViableDay = computedViable
                todayScore = s
            } else {
                todayScore = try await DailyScoreService.fetchToday(for: userID)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleCompletion(for habit: Habit) async {
        let isCurrentlyCompleted = completedHabitIDs.contains(habit.id)

        // 1. Optimistic UI update
        if isCurrentlyCompleted {
            completedHabitIDs.remove(habit.id)
        } else {
            completedHabitIDs.insert(habit.id)
        }

        do {
            // 2. Persist completion change
            if isCurrentlyCompleted {
                try await HabitCompletionService.uncomplete(habitID: habit.id, on: .now)
            } else {
                try await HabitCompletionService.complete(habitID: habit.id, userID: userID, on: .now)
            }

            // 3. Compute and persist streak
            let newStreak = try await computeNewStreak(for: habit, completing: !isCurrentlyCompleted)
            try await HabitService.updateStreak(habitID: habit.id, newStreak: newStreak)

            // 4. Sync streak in-memory so score calculation is accurate
            if let idx = habits.firstIndex(where: { $0.id == habit.id }) {
                habits[idx].currentStreak = newStreak
            }

            // 5. Recalculate and persist daily score (maxScore is frozen at load time)
            let (newScore, newIsViable) = recalculateScoreOnly()
            let currentMax = todayScore?.maxScore ?? 0
            try await DailyScoreService.upsertToday(
                userID: userID,
                score: newScore,
                maxScore: currentMax,
                isViableDay: newIsViable
            )
            todayScore?.score = newScore
            todayScore?.isViableDay = newIsViable
        } catch {
            // 6. Roll back optimistic update
            if isCurrentlyCompleted {
                completedHabitIDs.insert(habit.id)
            } else {
                completedHabitIDs.remove(habit.id)
            }
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Private

    private func computeNewStreak(for habit: Habit, completing: Bool) async throws -> Int {
        if completing {
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: .now)!
            let yesterdayCompletion = try await HabitCompletionService.fetchCompletion(for: habit.id, on: yesterday)
            return yesterdayCompletion != nil ? habit.currentStreak + 1 : 1
        } else {
            return max(0, habit.currentStreak - 1)
        }
    }

    // Returns score and isViableDay only — maxScore is NOT recomputed here.
    // Called from toggleCompletion() to keep maxScore frozen at its load-time value.
    private func recalculateScoreOnly() -> (score: Int, isViableDay: Bool) {
        let score = habits
            .filter { completedHabitIDs.contains($0.id) }
            .reduce(0) { $0 + $1.currentStreak }
        let mvdHabits = habits.filter { $0.isMVD }
        let isViableDay = !mvdHabits.isEmpty && mvdHabits.allSatisfy { completedHabitIDs.contains($0.id) }
        return (score, isViableDay)
    }

    // Full recompute — only called from loadAll() where DB streaks are authoritative.
    private func recalculateScore() -> (score: Int, maxScore: Int, isViableDay: Bool) {
        let (score, isViableDay) = recalculateScoreOnly()
        let maxScore = habits.reduce(0) { result, habit in
            let potentialStreak = completedHabitIDs.contains(habit.id)
                ? habit.currentStreak          // already completed today
                : habit.currentStreak + 1      // would increment on completion
            return result + potentialStreak
        }
        return (score, maxScore, isViableDay)
    }
}
