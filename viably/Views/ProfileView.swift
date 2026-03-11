//
//  ProfileView.swift
//  viably
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.dsTextPrimary)
                        .padding(.top, 32)
                } else {
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.dsCaption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                            .padding(.top, 12)
                    }
                    statsRow
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                }
            }
        }
        .background(Color.dsBackground.ignoresSafeArea())
    }

    // MARK: - Header

    private var header: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color.dsAccentPurple, Color(hex: "#3a4a2a")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 180)
            .frame(maxWidth: .infinity)

            VStack(spacing: 6) {
                avatar
                    .offset(y: 40)

                Spacer().frame(height: 40)
            }
        }
        .padding(.bottom, 48)
    }

    // MARK: - Avatar

    private var avatar: some View {
        Group {
            if let urlString = viewModel.profile?.avatarURL,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        fallbackAvatar
                    }
                }
            } else {
                fallbackAvatar
            }
        }
        .frame(width: 88, height: 88)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.dsBackground, lineWidth: 3))
    }

    private var fallbackAvatar: some View {
        ZStack {
            Circle().fill(Color.dsSurface)
            Image(systemName: "person.fill")
                .font(.system(size: 36))
                .foregroundColor(.dsTextMuted)
        }
    }

    // MARK: - Profile info

    private var profileInfo: some View {
        VStack(spacing: 4) {
            Text(viewModel.profile?.displayName ?? viewModel.profile?.username ?? "—")
                .font(.dsHeading)
                .foregroundColor(.dsTextPrimary)
            Text("@\(viewModel.profile?.username ?? "")")
                .font(.dsCaption)
                .foregroundColor(.dsTextMuted)
        }
    }

    // MARK: - Stats row

    private var statsRow: some View {
        VStack(spacing: 16) {
            profileInfo

            HStack(spacing: 12) {
                StatCard(label: "Best Streak", value: 0, color: .dsAccentOrange)
                StatCard(label: "High Score",  value: 0, color: .dsAccentLime)
                StatCard(label: "Friends",     value: 0, color: .dsAccentPurple)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let vm = ProfileViewModel(userID: UUID())
    vm.profile = Profile(
        id: UUID(),
        username: "ruitao",
        displayName: "Ruitao",
        avatarURL: nil,
        createdAt: Date()
    )
    return ProfileView(viewModel: vm)
}
