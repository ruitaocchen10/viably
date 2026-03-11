import SwiftUI

private let iconOptions = ["🏃", "📚", "💧", "🧘", "🎯", "💪", "😴", "✍️"]

struct NewHabitSheet: View {
    @ObservedObject var vm: MyHabitsViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedIcon: String? = nil
    @State private var isMVD = false
    @State private var isSaving = false

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
                                .font(.dsSemiBoldSectionLabel)
                                .foregroundColor(.dsTextPrimary)
                                .tint(.dsAccentLime)
                                .padding(14)
                                .background(Color.dsSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // Icon picker
                        fieldSection(label: "Icon") {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
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
                                        .foregroundColor(.dsTextPrimary)
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
                                        .font(.dsBoldSectionLabel)
                                        .foregroundColor(.dsBackground)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(canSave ? Color.dsAccentLime : Color.dsAccentLime.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(!canSave || isSaving)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
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
        await vm.createHabit(
            name: name.trimmingCharacters(in: .whitespaces),
            icon: selectedIcon,
            isMVD: isMVD
        )
        isSaving = false
        dismiss()
    }
}
