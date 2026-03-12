import SwiftUI

struct StatCard: View {
    let label: String
    let value: Int
    var color: Color = .dsAccentYellow
    var emoji: String? = nil

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 2) {
                if let emoji = emoji {
                    Text(emoji)
                        .font(.dsXBoldHeading)
                }
                Text("\(value)")
                    .font(.dsXBoldHeading)
                    .foregroundColor(color)
            }
            Text(label)
                .font(.dsCaption)
                .foregroundColor(.dsTextMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.dsSurface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.dsBorder, lineWidth: 1)
        )
    }
}
