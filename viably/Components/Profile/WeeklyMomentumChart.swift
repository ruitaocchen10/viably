//
//  WeeklyMomentumChart.swift
//  viably
//

import SwiftUI

struct WeeklyMomentumChart: View {
    let weekScores: [DailyScore]

    private struct DayBar {
        let label: String
        let ratio: Double
        let isViable: Bool
        let isToday: Bool
        let hasScore: Bool
    }

    private var bars: [DayBar] {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)  // 1=Sun, 2=Mon
        let daysFromMonday = (weekday + 5) % 7
        let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today)!

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current

        let scoreMap: [String: DailyScore] = Dictionary(
            uniqueKeysWithValues: weekScores.map { (formatter.string(from: $0.scoreDate), $0) }
        )

        let labels = ["M", "T", "W", "T", "F", "S", "S"]
        let todayString = formatter.string(from: today)

        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: monday)!
            let key = formatter.string(from: date)
            let score = scoreMap[key]
            let ratio = score.map { s in
                s.maxScore > 0 ? Double(s.score) / Double(s.maxScore) : 0.0
            } ?? 0.0
            return DayBar(
                label: labels[offset],
                ratio: min(max(ratio, 0), 1),
                isViable: score?.isViableDay ?? false,
                isToday: key == todayString,
                hasScore: score != nil
            )
        }
    }

    private let barMaxHeight: CGFloat = 80

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.dsSemiBoldSectionLabel)
                .foregroundColor(.dsTextMuted)

            VStack(spacing: 4) {
                // Bar area — fixed constant height, no GeometryReader
                HStack(spacing: 8) {
                    ForEach(Array(bars.enumerated()), id: \.offset) { _, bar in
                        barColumn(bar: bar)
                    }
                }

                // Labels row
                HStack(spacing: 8) {
                    ForEach(Array(bars.enumerated()), id: \.offset) { _, bar in
                        Text(bar.label)
                            .font(.dsCaption)
                            .fontWeight(bar.isToday ? .bold : .regular)
                            .foregroundColor(bar.isToday ? .dsTextPrimary : .dsTextMuted)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.dsSurface)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.dsBorder, lineWidth: 1))
    }

    private func barColumn(bar: DayBar) -> some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            if bar.hasScore {
                RoundedRectangle(cornerRadius: 4)
                    .fill(bar.isViable ? Color.dsAccentPurple : Color.dsTextMuted.opacity(0.4))
                    .frame(height: max(barMaxHeight * bar.ratio, 4))
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.dsSurface)
                    .frame(height: 4)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.dsBorder, lineWidth: 1))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: barMaxHeight)  // hard ceiling
        .clipped()                                             // safety net
    }
}
