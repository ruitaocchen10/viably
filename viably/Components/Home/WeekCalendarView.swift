import SwiftUI

struct WeekCalendarView: View {
    private let today = Date.now

    private var weekDays: [Date] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: today)
        // weekday: 1=Sun, 2=Mon, ..., 7=Sat → offset to Monday
        let daysFromMonday = (weekday == 1) ? 6 : weekday - 2
        let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today)!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(todayDateString)
                .font(.dsSemiBoldSectionLabel)
                .foregroundColor(.dsTextMuted)

            HStack(alignment: .top, spacing: 6) {
                ForEach(weekDays, id: \.self) { date in
                    DayCell(date: date, isToday: Calendar.current.isDateInToday(date))
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: today)
    }
}

private struct DayCell: View {
    let date: Date
    let isToday: Bool

    private var dayAbbrev: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return String(formatter.string(from: date).prefix(3)).lowercased()
    }

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(dayAbbrev)
                .font(.dsCaption)
                .foregroundColor(isToday ? .dsAccentLime : .dsTextMuted)
            Text(dayNumber)
                .font(isToday ? .dsBoldSubtitle : .dsBoldSectionLabel)
                .foregroundColor(.dsTextPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, isToday ? 14 : 10)
        .background(isToday ? Color(hex: "#1a2e1a") : Color.dsSurface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isToday ? Color.dsAccentLime : Color.dsBorder, lineWidth: 1)
        )
    }
}

#Preview {
    WeekCalendarView()
        .padding()
        .background(Color.dsBackground)
}
