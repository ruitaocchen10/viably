import SwiftUI

struct PostComposerView: View {
    let userID: UUID
    let score: Int
    let completedHabits: [Habit]
    @Binding var isPresented: Bool
    var onPosted: (() -> Void)?

    @State private var caption = ""
    @State private var selectedHabitIDs: Set<UUID> = []
    @State private var isPosting = false
    @State private var errorMessage: String?
    @State private var existingPost: Post?
    @State private var hasCheckedExisting = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.dsBackground.ignoresSafeArea()

                if !hasCheckedExisting {
                    ProgressView()
                        .tint(.dsAccentLime)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {

                            // Score preview
                            scorePreview

                            // Habits selection
                            if !completedHabits.isEmpty {
                                habitSelection
                            }

                            // Caption
                            captionField

                            if let error = errorMessage {
                                Text(error)
                                    .font(.dsCaption)
                                    .foregroundColor(.dsAccentOrange)
                            }

                            // Post button
                            postButton
                        }
                        .padding(16)
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle(existingPost == nil ? "Share Your Day" : "Update Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                        .foregroundColor(.dsTextMuted)
                }
            }
        }
        .task { await checkExistingPost() }
    }

    // MARK: - Subviews

    private var scorePreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today's Score")
                .font(.dsSemiBoldLabel)
                .foregroundColor(.dsTextMuted)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(score)")
                    .font(.dsXBoldHeading)
                    .foregroundColor(.dsAccentYellow)
                Text("pts")
                    .font(.dsSemiBoldLabel)
                    .foregroundColor(.dsTextMuted)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.dsSurface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.dsBorder, lineWidth: 1)
        )
    }

    private var habitSelection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Completed Habits")
                .font(.dsSemiBoldLabel)
                .foregroundColor(.dsTextMuted)

            FlowLayout(spacing: 8) {
                ForEach(completedHabits) { habit in
                    let selected = selectedHabitIDs.contains(habit.id)
                    Button {
                        if selected {
                            selectedHabitIDs.remove(habit.id)
                        } else {
                            selectedHabitIDs.insert(habit.id)
                        }
                    } label: {
                        HStack(spacing: 4) {
                            if let icon = habit.icon { Text(icon).font(.dsCaption) }
                            Text(habit.name).font(.dsCaption).lineLimit(1)
                            if selected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(selected ? Color.dsAccentLime : Color.dsSurface)
                        .foregroundColor(selected ? .black : .dsTextMuted)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(Color.dsBorder, lineWidth: selected ? 0 : 1)
                        )
                    }
                }
            }
        }
    }

    private var captionField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Caption (optional)")
                .font(.dsSemiBoldLabel)
                .foregroundColor(.dsTextMuted)

            TextField("How was your day?", text: $caption, axis: .vertical)
                .font(.dsSemiBoldCaption)
                .foregroundColor(.dsTextPrimary)
                .lineLimit(3...6)
                .padding(12)
                .background(Color.dsSurface)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.dsBorder, lineWidth: 1)
                )
        }
    }

    private var postButton: some View {
        Button {
            Task { await submitPost() }
        } label: {
            HStack {
                if isPosting {
                    ProgressView()
                        .tint(.dsBackground)
                        .scaleEffect(0.8)
                } else {
                    Text(existingPost == nil ? "Post to Feed" : "Update Post")
                        .font(.dsBoldSectionLabel)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.dsAccentLime)
            .foregroundColor(.black)
            .cornerRadius(14)
        }
        .disabled(isPosting)
    }

    // MARK: - Actions

    private func checkExistingPost() async {
        do {
            if let post = try await PostService.fetchMyPost(userID: userID) {
                existingPost = post
                caption = post.caption ?? ""
            }
        } catch {
            // Non-fatal — proceed without existing post data
        }
        // Always pre-select all currently completed habits
        selectedHabitIDs = Set(completedHabits.map { $0.id })
        hasCheckedExisting = true
    }

    private func submitPost() async {
        isPosting = true
        errorMessage = nil
        defer { isPosting = false }

        let habitsToPost = completedHabits.filter { selectedHabitIDs.contains($0.id) }

        do {
            try await PostService.createPost(
                userID: userID,
                score: score,
                caption: caption.isEmpty ? nil : caption,
                habits: habitsToPost
            )
            onPosted?()
            isPresented = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
