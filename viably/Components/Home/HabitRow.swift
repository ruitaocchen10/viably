import SwiftUI
import UIKit

struct HabitRow: View {
    let habit: Habit
    let isCompleted: Bool
    let onTap: () -> Void

    @State private var pressProgress: CGFloat = 0.0

    var body: some View {
        HStack(spacing: 12) {
            // Icon placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "#2a2a3a"))
                    .frame(width: 48, height: 48)
                if let icon = habit.icon {
                    Text(icon)
                        .font(.system(size: 26))
                }
            }
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
            HStack(spacing: 4) {
                Text("🔥")
                    .font(.system(size: 18))
                Text("\(habit.currentStreak)")
                    .font(.dsXBoldHeading)
                    .foregroundColor(.dsAccentYellow)
            }
        }
        .padding(12)
        .background(
            ZStack(alignment: .leading) {
                isCompleted ? Color(hex: "#162316") : Color.dsSurface
                GeometryReader { geo in
                    Rectangle()
                        .fill(Color.dsAccentLime.opacity(0.25))
                        .frame(width: geo.size.width * pressProgress)
                }
            }
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .onLongPressGesture(minimumDuration: 0.6, pressing: { isPressing in
            guard !isCompleted else { return }
            withAnimation(isPressing ? .linear(duration: 0.6) : .spring(duration: 0.2)) {
                pressProgress = isPressing ? 1.0 : 0.0
            }
        }, perform: {
            guard !isCompleted else { return }
            let haptic = UIImpactFeedbackGenerator(style: .medium)
            haptic.impactOccurred()
            pressProgress = 0.0
            onTap()
        })
    }
}
