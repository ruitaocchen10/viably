import SwiftUI

struct MyHabitsView: View {
    @StateObject private var vm = MyHabitsViewModel()
    @State private var showNewHabitSheet = false
    @State private var habitToEdit: Habit? = nil
    @State private var habitToDelete: Habit? = nil

    private var deleteAlertBinding: Binding<Bool> {
        Binding(get: { habitToDelete != nil }, set: { if !$0 { habitToDelete = nil } })
    }

    var body: some View {
        ZStack {
            Color.dsBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack {
                        Text("My Habits")
                            .font(.dsXBoldTitle)
                            .foregroundColor(.dsTextPrimary)
                        Spacer()
                        Button {
                            showNewHabitSheet = true
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.dsAccentLime)
                                    .frame(width: 32, height: 32)
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.dsBackground)
                            }
                        }
                    }
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
        .sheet(isPresented: $showNewHabitSheet) {
            NewHabitSheet(vm: vm)
        }
        .sheet(item: $habitToEdit) { habit in
            EditHabitSheet(vm: vm, habit: habit)
        }
        .alert("Delete Habit?", isPresented: deleteAlertBinding) {
            Button("Delete", role: .destructive) {
                if let habit = habitToDelete {
                    Task { await vm.deleteHabit(id: habit.id) }
                }
                habitToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                habitToDelete = nil
            }
        } message: {
            Text("This will permanently delete the habit and its streak.")
        }
        .task {
            await vm.loadHabits()
        }
    }

    // MARK: - Subviews

    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("🔥")
                .font(.system(size: 56))

            VStack(spacing: 6) {
                Text("What will you build?")
                    .font(.dsXBoldSubtitle)
                    .foregroundColor(.dsTextPrimary)
                Text("Every streak starts with day 1.")
                    .font(.dsSemiBoldLabel)
                    .foregroundColor(.dsTextMuted)
            }

            Button {
                showNewHabitSheet = true
            } label: {
                Text("Add your first habit")
                    .font(.dsBoldSectionLabel)
                    .foregroundColor(.dsBackground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.dsAccentLime)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 32)
            .padding(.top, 8)
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
                    habits: vm.mvdHabits,
                    onEdit: { habitToEdit = $0 },
                    onDelete: { habitToDelete = $0 }
                )
            }

            if !vm.otherHabits.isEmpty {
                HabitSection(
                    title: "Other Habits",
                    subtitle: nil,
                    habits: vm.otherHabits,
                    onEdit: { habitToEdit = $0 },
                    onDelete: { habitToDelete = $0 }
                )
            }

            if !vm.inactiveHabits.isEmpty {
                HabitSection(
                    title: "Inactive Habits",
                    subtitle: nil,
                    habits: vm.inactiveHabits,
                    muted: true,
                    onEdit: { habitToEdit = $0 },
                    onDelete: { habitToDelete = $0 }
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
    var onEdit: (Habit) -> Void = { _ in }
    var onDelete: (Habit) -> Void = { _ in }

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
                    HabitLibraryRow(
                        habit: habit,
                        onEdit: { onEdit(habit) },
                        onDelete: { onDelete(habit) }
                    )
                    if habit.id != habits.last?.id {
                        Divider()
                            .background(Color.dsBorder)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                    }
                }
            }
            .background(Color.dsSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    NavigationStack {
        MyHabitsView()
    }
}
