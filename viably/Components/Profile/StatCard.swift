import SwiftUI

struct StatCard: View {
    let label: String
    let value: Int
    var color: Color = .dsAccentYellow

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.dsHeading)
                .foregroundColor(color)
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
