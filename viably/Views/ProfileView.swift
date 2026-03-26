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
    @State private var showingDeleteAccountAlert = false
    @State private var showingFriends = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.dsCaption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                        .padding(.top, 12)
                }
                if let error = authVM.errorMessage {
                    Text(error)
                        .font(.dsCaption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                        .padding(.top, 4)
                }
                statsRow
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                signOutButton
                    .padding(.horizontal, 16)
                    .padding(.top, 32)
                deleteAccountButton
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                privacyPolicyButton
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
            }
        }
        .overlay { if viewModel.isLoading { AppLoadingView() } }
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
        AvatarView(avatarURL: viewModel.profile?.avatarURL, size: 88, borderColor: .dsBackground)
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
                .font(.dsBoldSectionLabel)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
        .buttonStyle(.borderedProminent)
        .tint(.red)
        .alert("Sign Out", isPresented: $showingSignOutAlert) {
            Button("Sign Out", role: .destructive) { Task { await authVM.signOut() } }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }

    // MARK: - Delete Account

    private var deleteAccountButton: some View {
        Button(role: .destructive) {
            showingDeleteAccountAlert = true
        } label: {
            Text("Delete Account")
                .font(.dsSemiBoldSectionLabel)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
        .buttonStyle(.bordered)
        .tint(.red)
        .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
            Button("Delete Account", role: .destructive) { Task { await authVM.deleteAccount() } }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete your account and all your data. This cannot be undone.")
        }
    }

    // MARK: - Privacy Policy

    private var privacyPolicyButton: some View {
        Link(destination: URL(string: "https://www.notion.so/Privacy-Policy-for-viablyy-3233b0f9010e8099bf82cab56a3bdf87")!) {
            Text("Privacy Policy")
                .font(.dsSemiBoldSectionLabel)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
        .buttonStyle(.bordered)
        .tint(.dsTextMuted)
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
