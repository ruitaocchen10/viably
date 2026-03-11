import SwiftUI

struct HabitRow: View {
    let habit: Habit
    let isCompleted: Bool
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Icon placeholder
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: "#2a2a3a"))
                .frame(width: 48, height: 48)

            // Name + MVD badge
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.dsSemiBoldSectionLabel)
                    .foregroundColor(isCompleted ? .dsAccentLime : .dsTextPrimary)

                if habit.isMVD {
                    Text("MVD")
                        .font(.dsCaption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.dsAccentPurple)
                        .cornerRadius(6)
                }
            }

            Spacer()

            // Streak number
            Text("\(habit.currentStreak)")
                .font(.dsXBoldHeading)
                .foregroundColor(.dsAccentYellow)
        }
        .padding(12)
        .background(isCompleted ? Color(hex: "#162316") : Color.dsSurface)
        .cornerRadius(16)
        .onTapGesture { onTap() }
    }
}
