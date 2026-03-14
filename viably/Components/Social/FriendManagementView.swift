import SwiftUI

struct FriendManagementView: View {
    @StateObject private var viewModel = FriendManagementViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.dsBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Friends")
                        .font(.dsXBoldTitle)
                        .foregroundColor(.dsTextPrimary)
                    Spacer()
                    Button { dismiss() } label: {
                        ZStack {
                            Circle()
                                .fill(Color.dsAccentLime)
                                .frame(width: 32, height: 32)
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.dsBackground)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 20)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Add a Friend section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Add a Friend")
                                .font(.dsBoldSubtitle)
                                .foregroundColor(.dsTextPrimary)
                                .padding(.horizontal, 16)

                            HStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.dsTextMuted)
                                TextField("Search by username", text: $viewModel.searchText)
                                    .font(.dsSemiBoldLabel)
                                    .foregroundColor(.dsTextPrimary)
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.dsAccentLime)
                                        .scaleEffect(0.8)
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(Color.dsSurface)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.dsBorder, lineWidth: 1)
                            )
                            .padding(.horizontal, 16)

                            if !viewModel.searchResults.isEmpty {
                                VStack(spacing: 0) {
                                    ForEach(viewModel.searchResults) { profile in
                                        SearchResultRow(
                                            profile: profile,
                                            isSent: viewModel.sentRequests.contains(profile.id)
                                        ) {
                                            Task { await viewModel.sendRequest(to: profile.id) }
                                        }
                                        if profile.id != viewModel.searchResults.last?.id {
                                            Divider()
                                                .background(Color.dsBorder)
                                                .padding(.horizontal, 16)
                                        }
                                    }
                                }
                                .background(Color.dsSurface)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.dsBorder, lineWidth: 1)
                                )
                                .padding(.horizontal, 16)
                            }
                        }

                        // Pending Requests section
                        if !viewModel.pendingRequests.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Pending Requests")
                                    .font(.dsBoldSubtitle)
                                    .foregroundColor(.dsTextPrimary)
                                    .padding(.horizontal, 16)

                                VStack(spacing: 0) {
                                    ForEach(viewModel.pendingRequests) { friendship in
                                        PendingRequestRow(friendship: friendship) {
                                            Task { await viewModel.acceptRequest(friendship) }
                                        } onDecline: {
                                            Task { await viewModel.declineRequest(friendship) }
                                        }
                                        if friendship.id != viewModel.pendingRequests.last?.id {
                                            Divider()
                                                .background(Color.dsBorder)
                                                .padding(.horizontal, 16)
                                        }
                                    }
                                }
                                .background(Color.dsSurface)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.dsBorder, lineWidth: 1)
                                )
                                .padding(.horizontal, 16)
                            }
                        }

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.dsCaption)
                                .foregroundColor(.dsAccentOrange)
                                .padding(12)
                                .frame(maxWidth: .infinity)
                                .background(Color.dsSurface)
                                .cornerRadius(8)
                                .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .task { await viewModel.loadPendingRequests() }
        .onChange(of: viewModel.searchText) { _, newValue in
            Task {
                try? await Task.sleep(for: .milliseconds(300))
                guard viewModel.searchText == newValue else { return }
                await viewModel.searchUsers()
            }
        }
    }
}

// MARK: - Search Result Row

private struct SearchResultRow: View {
    let profile: Profile
    let isSent: Bool
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ProfileAvatar(avatarURL: profile.avatarURL, size: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(profile.displayName ?? profile.username)
                    .font(.dsSemiBoldLabel)
                    .foregroundColor(.dsTextPrimary)
                Text("@\(profile.username)")
                    .font(.dsCaption)
                    .foregroundColor(.dsTextMuted)
            }

            Spacer()

            Button(action: onAdd) {
                Text(isSent ? "Sent" : "Add")
                    .font(.dsSemiBoldCaption)
                    .foregroundColor(isSent ? .dsTextMuted : .dsBackground)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(isSent ? Color.dsSurface : Color.dsAccentLime)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isSent ? Color.dsBorder : Color.clear, lineWidth: 1)
                    )
            }
            .disabled(isSent)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Pending Request Row

private struct PendingRequestRow: View {
    let friendship: Friendship
    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ProfileAvatar(avatarURL: nil, size: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text("User \(friendship.requesterID.uuidString.prefix(8))")
                    .font(.dsSemiBoldLabel)
                    .foregroundColor(.dsTextPrimary)
                Text("Wants to be friends")
                    .font(.dsCaption)
                    .foregroundColor(.dsTextMuted)
            }

            Spacer()

            HStack(spacing: 8) {
                Button(action: onDecline) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.dsTextMuted)
                        .frame(width: 32, height: 32)
                        .background(Color.dsBackground)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.dsBorder, lineWidth: 1))
                }

                Button(action: onAccept) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.dsBackground)
                        .frame(width: 32, height: 32)
                        .background(Color.dsAccentLime)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Profile Avatar

private struct ProfileAvatar: View {
    let avatarURL: String?
    let size: CGFloat

    var body: some View {
        Group {
            if let urlString = avatarURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.dsIconBackground
                }
            } else {
                Color.dsIconBackground
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.dsTextMuted)
                            .font(.system(size: size * 0.45))
                    )
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
