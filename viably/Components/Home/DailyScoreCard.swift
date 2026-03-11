import SwiftUI

struct DailyScoreCard: View {
    let score: Int
    let maxScore: Int
    let isViableDay: Bool
    let progressFraction: Double
    let mvdHabitsRemaining: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text("Daily Score")
                    .font(.dsSemiBoldLabel)
                    .foregroundColor(.dsTextMuted)
                Spacer()
                Text("\(score)/\(maxScore)")
                    .font(.dsXBoldHeading)
                    .foregroundColor(.dsAccentLime)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)
                    Capsule()
                        .fill(LinearGradient(
                            colors: [.dsAccentPurple, .dsAccentLime],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: max(0, geo.size.width * progressFraction), height: 8)
                }
            }
            .frame(height: 8)

            // Status line
            if isViableDay {
                Text("Minimum Viable Day achieved!")
                    .font(.dsCaption)
                    .foregroundColor(.dsAccentLime)
            } else if mvdHabitsRemaining > 0 {
                Text("\(mvdHabitsRemaining) habit\(mvdHabitsRemaining == 1 ? "" : "s") to reach ")
                    .font(.dsCaption)
                    .foregroundColor(.dsTextMuted)
                + Text("Minimum Viable Day")
                    .font(.dsCaption)
                    .bold()
                    .foregroundColor(.dsAccentLime)
            } else {
                Text("Complete your habits to build your score")
                    .font(.dsCaption)
                    .foregroundColor(.dsTextMuted)
            }
        }
        .padding(16)
        .background(Color.dsSurface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.dsBorder, lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        DailyScoreCard(score: 11, maxScore: 24, isViableDay: false, progressFraction: 0.46, mvdHabitsRemaining: 2)
        DailyScoreCard(score: 24, maxScore: 24, isViableDay: true, progressFraction: 1.0, mvdHabitsRemaining: 0)
        DailyScoreCard(score: 0, maxScore: 0, isViableDay: false, progressFraction: 0, mvdHabitsRemaining: 0)
    }
    .padding()
    .background(Color.dsBackground)
}
