import SwiftUI

struct HabitLibraryRow: View {
    let habit: Habit
    var onEdit: () -> Void = {}
    var onDelete: () -> Void = {}

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.dsBackground)
                    .frame(width: 40, height: 40)
                Text(habit.icon ?? "⭐")
                    .font(.system(size: 20))
            }

            // Name + MVD badge
            VStack(alignment: .leading, spacing: 2) {
                Text(habit.name)
                    .font(.dsSemiBoldSectionLabel)
                    .foregroundColor(.dsTextPrimary)
                if habit.isMVD {
                    Text("MVD")
                        .font(.dsCaption)
                        .foregroundColor(.dsAccentPurple)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.dsAccentPurple.opacity(0.15))
                        .clipShape(Capsule())
                }
            }

            Spacer()

            // Streak
            if habit.currentStreak > 0 {
                HStack(spacing: 2) {
                    Text("🔥")
                        .font(.system(size: 12))
                    Text("\(habit.currentStreak)")
                        .font(.dsSemiBoldCaption)
                        .foregroundColor(.dsTextMuted)
                }
            }

            // Action buttons
            HStack(spacing: 4) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.dsTextMuted)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.dsTextMuted)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}
