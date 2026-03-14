//
//  ProfileView.swift
//  viably
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showingEdit = false
    @State private var showingSignOutAlert = false
    @State private var showingFriends = false

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
                    signOutButton
                        .padding(.horizontal, 16)
                        .padding(.top, 32)
                        .padding(.bottom, 24)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color.dsBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { showingEdit = true }
                    .foregroundColor(.white)
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditProfileView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingFriends) {
            FriendManagementView()
        }
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
                    case .failure(let error):
                        let _ = { print("[Avatar] load failed: \(error)") }()
                        fallbackAvatar
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

    // MARK: - Sign Out

    private var signOutButton: some View {
        Button(role: .destructive) {
            showingSignOutAlert = true
        } label: {
            Text("Sign Out")
                .font(.dsSemiBoldSectionLabel)
                .frame(maxWidth: .infinity)
        }
        .alert("Sign Out", isPresented: $showingSignOutAlert) {
            Button("Sign Out", role: .destructive) { Task { await authVM.signOut() } }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }

    // MARK: - Stats row

    private var statsRow: some View {
        VStack(spacing: 16) {
            profileInfo

            HStack(spacing: 12) {
                StatCard(label: "Best Streak", value: viewModel.bestStreak, color: .dsAccentOrange, emoji: "🔥")
                StatCard(label: "High Score",  value: viewModel.highScore, color: .dsAccentLime)
                Button { showingFriends = true } label: {
                    StatCard(label: "Friends", value: viewModel.friendsCount, color: .dsAccentPurple)
                }
                .buttonStyle(.plain)
            }

            WeeklyMomentumChart(weekScores: viewModel.weekScores)
        }
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
}
