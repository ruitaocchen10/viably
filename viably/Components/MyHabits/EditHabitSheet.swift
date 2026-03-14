import SwiftUI

private let iconOptions = ["🏃", "📚", "💧", "🧘", "🎯", "💪", "😴", "✍️"]


struct EditHabitSheet: View {
    @ObservedObject var vm: MyHabitsViewModel
    let habit: Habit
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var description: String
    @State private var selectedIcon: String?
    @State private var isMVD: Bool
    @State private var isSaving = false

    @FocusState private var isNameFocused: Bool
    @FocusState private var isDescFocused: Bool

    init(vm: MyHabitsViewModel, habit: Habit) {
        self.vm = vm
        self.habit = habit
        _name = State(initialValue: habit.name)
        _description = State(initialValue: habit.description ?? "")
        _selectedIcon = State(initialValue: habit.icon)
        _isMVD = State(initialValue: habit.isMVD)
    }

    private var canSave: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.dsBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        // Name field
                        fieldSection(label: "Habit Name") {
                            TextField("e.g. Morning run", text: $name)
                                .focused($isNameFocused)
                                .font(.dsSemiBoldSectionLabel)
                                .foregroundColor(.dsTextPrimary)
                                .tint(.dsAccentLime)
                                .padding(14)
                                .background(Color.dsSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .contentShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // Description field
                        fieldSection(label: "Description") {
                            TextField("e.g. Run 30 minutes outside", text: $description)
                                .focused($isDescFocused)
                                .font(.dsSemiBoldSectionLabel)
                                .foregroundColor(.dsTextPrimary)
                                .tint(.dsAccentLime)
                                .padding(14)
                                .background(Color.dsSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .contentShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // Icon picker
                        fieldSection(label: "Icon") {
                            FlowLayout(spacing: 8) {
                                ForEach(iconOptions, id: \.self) { emoji in
                                    iconCell(emoji)
                                }
                            }
                        }

                        // Options
                        fieldSection(label: "Options") {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Minimum Viable Day")
                                        .font(.dsSemiBoldSectionLabel)
                                        .foregroundColor(.dsAccentPurple)
                                    Text("This habit must be done for a viable day")
                                        .font(.dsCaption)
                                        .foregroundColor(.dsTextMuted)
                                }
                                Spacer()
                                Toggle("", isOn: $isMVD)
                                    .tint(.dsAccentPurple)
                                    .labelsHidden()
                            }
                            .padding(14)
                            .background(Color.dsSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // Save button
                        Button {
                            Task { await save() }
                        } label: {
                            ZStack {
                                if isSaving {
                                    ProgressView()
                                        .tint(.dsBackground)
                                } else {
                                    Text("Save Habit")
                                        .font(.dsXBoldSubtitle)
                                        .foregroundColor(.dsBackground)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(canSave ? Color.dsAccentLime : Color.dsAccentLime.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(!canSave || isSaving)
                    }
                    .padding(20)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Edit Habit")
                        .font(.dsSemiBoldSectionLabel)
                        .foregroundColor(.dsTextPrimary)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .font(.dsSemiBoldLabel)
                        .foregroundColor(.dsTextMuted)
                }
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func fieldSection<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.dsSemiBoldLabel)
                .foregroundColor(.dsTextMuted)
            content()
        }
    }

    private func iconCell(_ emoji: String) -> some View {
        let isSelected = selectedIcon == emoji
        return Button {
            selectedIcon = selectedIcon == emoji ? nil : emoji
        } label: {
            Text(emoji)
                .font(.system(size: 28))
                .frame(width: 48, height: 48)
                .background(isSelected ? Color.dsAccentLime.opacity(0.2) : Color.dsSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.dsAccentLime : Color.dsBorder, lineWidth: isSelected ? 2 : 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func save() async {
        isSaving = true
        let trimmedDescription = description.trimmingCharacters(in: .whitespaces)
        await vm.updateHabit(
            id: habit.id,
            name: name.trimmingCharacters(in: .whitespaces),
            icon: selectedIcon,
            description: trimmedDescription.isEmpty ? nil : trimmedDescription,
            isMVD: isMVD
        )
        isSaving = false
        dismiss()
    }
}
