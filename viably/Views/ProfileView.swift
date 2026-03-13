//
//  ProfileView.swift
//  viably
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

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
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [Color.dsAccentPurple, Color.dsGradientAccentEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 180)
            .frame(maxWidth: .infinity)

            avatar
                .offset(y: 40)
                .padding(.leading, 16)
        }
        .padding(.bottom, 24)
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
        VStack(alignment: .leading, spacing: 0) {
            Text(viewModel.profile?.displayName ?? viewModel.profile?.username ?? "—")
                .font(.dsXBoldHeading)
                .foregroundColor(.dsTextPrimary)
            Text("@\(viewModel.profile?.username ?? "")")
                .font(.dsSemiBoldSectionLabel)
                .foregroundColor(.dsTextMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Stats row

    private var statsRow: some View {
        VStack(spacing: 16) {
            profileInfo

            HStack(spacing: 12) {
                StatCard(label: "Best Streak", value: 0, color: .dsAccentOrange, emoji: "🔥")
                StatCard(label: "High Score",  value: 0, color: .dsAccentLime)
                StatCard(label: "Friends",     value: 0, color: .dsAccentPurple)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
}
