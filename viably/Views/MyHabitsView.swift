import SwiftUI

struct MyHabitsView: View {
    @StateObject private var vm = MyHabitsViewModel()
    @State private var showNewHabitSheet = false

    var body: some View {
        ZStack {
            Color.dsBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    Text("My Habits")
                        .font(.dsXBoldHeading)
                        .foregroundColor(.dsTextPrimary)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 24)

                    if vm.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                                .tint(.dsAccentLime)
                            Spacer()
                        }
                        .padding(.top, 60)
                    } else if vm.habits.isEmpty {
                        emptyState
                    } else {
                        habitSections
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showNewHabitSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.dsAccentLime)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showNewHabitSheet) {
            NewHabitSheet(vm: vm)
        }
        .task {
            await vm.loadHabits()
        }
    }

    // MARK: - Subviews

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "plus.circle.dashed")
                .font(.system(size: 48))
                .foregroundColor(.dsTextMuted)
            Text("No habits yet")
                .font(.dsBoldSectionLabel)
                .foregroundColor(.dsTextPrimary)
            Text("Tap + to create your first habit")
                .font(.dsSemiBoldLabel)
                .foregroundColor(.dsTextMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    private var habitSections: some View {
        VStack(alignment: .leading, spacing: 24) {
            if !vm.mvdHabits.isEmpty {
                HabitSection(
                    title: "Minimum Viable Day",
                    subtitle: "Complete these habits and your day is a win, no matter what",
                    habits: vm.mvdHabits
                )
            }

            if !vm.otherHabits.isEmpty {
                HabitSection(
                    title: "Other Habits",
                    subtitle: nil,
                    habits: vm.otherHabits
                )
            }

            if !vm.inactiveHabits.isEmpty {
                HabitSection(
                    title: "Inactive Habits",
                    subtitle: nil,
                    habits: vm.inactiveHabits,
                    muted: true
                )
            }
        }
        .padding(.bottom, 32)
    }
}

// MARK: - HabitSection

private struct HabitSection: View {
    let title: String
    let subtitle: String?
    let habits: [Habit]
    var muted: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.dsBoldSectionLabel)
                    .foregroundColor(muted ? .dsTextMuted : .dsTextPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.dsCaption)
                        .foregroundColor(.dsTextMuted)
                }
            }
            .padding(.horizontal, 20)

            VStack(spacing: 0) {
                ForEach(habits) { habit in
                    HabitLibraryRow(habit: habit)
                    if habit.id != habits.last?.id {
                        Divider()
                            .background(Color.dsBorder)
                            .padding(.leading, 20)
                    }
                }
            }
            .background(Color.dsSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - HabitLibraryRow

private struct HabitLibraryRow: View {
    let habit: Habit

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.dsBackground)
                    .frame(width: 40, height: 40)
                Text(habit.icon ?? "⭐")
                    .font(.system(size: 20))
            }

            // Name + MVD badge
            VStack(alignment: .leading, spacing: 2) {
                Text(habit.name)
                    .font(.dsSemiBoldSectionLabel)
                    .foregroundColor(.dsTextPrimary)
                if habit.isMVD {
                    Text("MVD")
                        .font(.dsCaption)
                        .foregroundColor(.dsAccentPurple)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.dsAccentPurple.opacity(0.15))
                        .clipShape(Capsule())
                }
            }

            Spacer()

            // Streak
            if habit.currentStreak > 0 {
                HStack(spacing: 2) {
                    Text("🔥")
                        .font(.system(size: 12))
                    Text("\(habit.currentStreak)")
                        .font(.dsSemiBoldCaption)
                        .foregroundColor(.dsTextMuted)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    NavigationStack {
        MyHabitsView()
    }
}
