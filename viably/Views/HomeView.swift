//
//  HomeView.swift
//  viably
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

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
                            Circle()
                                .fill(Color.dsSurface)
                                .frame(width: 44, height: 44)
                        }

                        WeekCalendarView()

                        DailyScoreCard(
                            score: viewModel.scoreValue,
                            maxScore: viewModel.maxScoreValue,
                            isViableDay: viewModel.isViableDay,
                            progressFraction: viewModel.progressFraction,
                            mvdHabitsRemaining: viewModel.mvdHabitsRemaining
                        )

                        // Habits section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Habits")
                                .font(.dsXBoldSubtitle)
                                .foregroundColor(.dsTextPrimary)

                            if viewModel.habits.isEmpty {
                                Text("No habits yet. Create your first habit!")
                                    .font(.dsCaption)
                                    .foregroundColor(.dsTextMuted)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 24)
                            } else {
                                ForEach(viewModel.habits) { habit in
                                    HabitRow(
                                        habit: habit,
                                        isCompleted: viewModel.completedHabitIDs.contains(habit.id)
                                    ) {
                                        Task { await viewModel.toggleCompletion(for: habit) }
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
    }
}

#Preview {
    HomeView()
}
