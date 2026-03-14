import SwiftUI

struct HabitTagBadge: View {
    let name: String
    let icon: String?

    var body: some View {
        HStack(spacing: 4) {
            if let icon {
                Text(icon)
                    .font(.dsCaption)
            }
            Text(name)
                .font(.dsCaption)
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.dsAccentLime)
        .foregroundColor(.black)
        .clipShape(Capsule())
    }
}

#Preview {
    HStack {
        HabitTagBadge(name: "Run 5K", icon: "🏃")
        HabitTagBadge(name: "Meditate", icon: "🧘")
        HabitTagBadge(name: "Read", icon: nil)
    }
    .padding()
    .background(Color.dsBackground)
}
