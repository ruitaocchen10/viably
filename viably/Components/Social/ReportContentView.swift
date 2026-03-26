import SwiftUI

enum ReportTarget {
    case post(Post)
    case reply(Reply)
}

struct ReportContentView: View {
    let target: ReportTarget
    let reporterID: UUID
    @Environment(\.dismiss) private var dismiss

    @State private var selectedReason = "spam"
    @State private var isSubmitting = false
    @State private var didSubmit = false

    private let reasons: [(String, String)] = [
        ("spam", "Spam"),
        ("harassment", "Harassment"),
        ("inappropriate", "Inappropriate content"),
        ("other", "Other")
    ]

    var body: some View {
        NavigationStack {
            Group {
                if didSubmit {
                    confirmationView
                } else {
                    reasonPickerView
                }
            }
            .navigationTitle(didSubmit ? "" : "Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !didSubmit {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                            .foregroundColor(.dsTextMuted)
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Reason picker

    private var reasonPickerView: some View {
        VStack(spacing: 0) {
            List(reasons, id: \.0) { id, label in
                Button {
                    selectedReason = id
                } label: {
                    HStack {
                        Text(label)
                            .font(.dsSemiBoldLabel)
                            .foregroundColor(.dsTextPrimary)
                        Spacer()
                        if selectedReason == id {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.dsAccentLime)
                        }
                    }
                }
                .listRowBackground(Color.dsSurface)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)

            Button {
                Task { await submit() }
            } label: {
                Group {
                    if isSubmitting {
                        ProgressView().tint(.dsBackground)
                    } else {
                        Text("Submit Report")
                            .font(.dsBoldSectionLabel)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.dsAccentLime)
                .foregroundColor(.dsBackground)
                .cornerRadius(12)
            }
            .disabled(isSubmitting)
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Color.dsBackground.ignoresSafeArea())
    }

    // MARK: - Confirmation

    private var confirmationView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 52))
                .foregroundColor(.dsAccentLime)
            Text("Report submitted")
                .font(.dsBoldSubtitle)
                .foregroundColor(.dsTextPrimary)
            Text("Thanks — we'll review this and take action if needed.")
                .font(.dsCaption)
                .foregroundColor(.dsTextMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.dsBackground.ignoresSafeArea())
    }

    // MARK: - Submit

    private func submit() async {
        isSubmitting = true
        do {
            switch target {
            case .post(let post):
                try await ModerationService.reportPost(
                    reporterID: reporterID,
                    postID: post.id,
                    postUserID: post.userID,
                    reason: selectedReason
                )
            case .reply(let reply):
                try await ModerationService.reportReply(
                    reporterID: reporterID,
                    replyID: reply.id,
                    replyUserID: reply.userID,
                    reason: selectedReason
                )
            }
            didSubmit = true
            try? await Task.sleep(for: .seconds(1.5))
            dismiss()
        } catch {
            isSubmitting = false
        }
    }
}
