//
//  HomeView.swift
//  viably
//

import SwiftUI
import Supabase

struct HomeView: View {
    @Binding var selectedTab: Int
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var profileVM = ProfileViewModel()
    @AppStorage("hasSeenHoldCoachMark") private var hasSeenCoachMark = false
    @State private var showComposer = false

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        let timeOfDay: String
        switch hour {
        case 5..<12: timeOfDay = "Morning"
        case 12..<17: timeOfDay = "Afternoon"
        case 17..<21: timeOfDay = "Evening"
        default: timeOfDay = "Night"
        }
        return "\(timeOfDay),\n\(viewModel.userName)"
    }

    var body: some View {
        ZStack {
            Color.dsBackground.ignoresSafeArea()

            if viewModel.isLoading && viewModel.habits.isEmpty {
                ProgressView()
                    .tint(.dsAccentLime)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        HStack(alignment: .top) {
                            Text(greeting)
                                .font(.dsXBoldTitle)
                                .foregroundColor(.dsTextPrimary)
                            Spacer()
                            Button { selectedTab = 3 } label: {
                                Group {
                                    if let urlString = profileVM.profile?.avatarURL,
                                       let url = URL(string: urlString) {
                                        AsyncImage(url: url) { image in
                                            image.resizable().scaledToFill()
                                        } placeholder: {
                                            Color.dsSurface
                                        }
                                    } else {
                                        Color.dsSurface
                                    }
                                }
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                            }
                        }

                        WeekCalendarView()

                        DailyScoreCard(
                            score: viewModel.scoreValue,
                            maxScore: viewModel.maxScoreValue,
                            isViableDay: viewModel.isViableDay,
                            progressFraction: viewModel.progressFraction,
                            mvdHabitsRemaining: viewModel.mvdHabitsRemaining
                        )

                        // Share Day
                        Button {
                            showComposer = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Share Day")
                                    .font(.dsBoldSectionLabel)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.dsSurface)
                            .foregroundColor(.dsAccentLime)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.dsAccentLime.opacity(0.4), lineWidth: 1)
                            )
                        }

                        // Habits section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Habits")
                                .font(.dsXBoldSubtitle)
                                .foregroundColor(.dsTextPrimary)

                            if viewModel.habits.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "checkmark.circle.dashed")
                                        .font(.system(size: 48))
                                        .foregroundColor(.dsAccentLime)
                                    VStack(spacing: 8) {
                                        Text("Start building streaks")
                                            .font(.dsBoldSubtitle)
                                            .foregroundColor(.dsTextPrimary)
                                        Text("Add your first habit and start tracking your progress.")
                                            .font(.dsSemiBoldCaption)
                                            .foregroundColor(.dsTextMuted)
                                            .multilineTextAlignment(.center)
                                    }
                                    Button("Add your first habit") {
                                        selectedTab = 2
                                    }
                                    .font(.dsBoldSectionLabel)
                                    .foregroundColor(.dsBackground)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.dsAccentLime)
                                    .cornerRadius(12)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 24)
                            } else {
                                ForEach(Array(viewModel.sortedHabits.enumerated()), id: \.element.id) { index, habit in
                                    HabitRow(
                                        habit: habit,
                                        isCompleted: viewModel.completedHabitIDs.contains(habit.id),
                                        onUncomplete: {
                                            Task { await viewModel.toggleCompletion(for: habit) }
                                        }
                                    ) {
                                        if !hasSeenCoachMark {
                                            withAnimation { hasSeenCoachMark = true }
                                        }
                                        Task { await viewModel.toggleCompletion(for: habit) }
                                    }
                                    .overlay(alignment: .bottom) {
                                        if index == 0 && !hasSeenCoachMark {
                                            Text("Hold to complete")
                                                .font(.caption)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                                .background(Capsule().fill(Color.dsAccentLime.opacity(0.9)))
                                                .foregroundColor(.black)
                                                .offset(y: 28)
                                                .transition(.opacity.combined(with: .scale))
                                                .zIndex(1)
                                        }
                                    }
                                }
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
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .padding(.bottom, 32)
                }
            }
        }
        .task { await viewModel.loadAll() }
        .sheet(isPresented: $showComposer) {
            if let userID = supabase.auth.currentUser?.id {
                PostComposerView(
                    userID: userID,
                    score: viewModel.scoreValue,
                    completedHabits: viewModel.habits.filter { viewModel.completedHabitIDs.contains($0.id) },
                    isPresented: $showComposer
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
}
