import SwiftUI

struct AvatarView: View {
    let avatarURL: String?
    let size: CGFloat
    var borderColor: Color? = nil

    var body: some View {
        Group {
            if let urlString = avatarURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image): image.resizable().scaledToFill()
                    default: fallback
                    }
                }
            } else {
                fallback
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(borderColor.map { Circle().stroke($0, lineWidth: 3) })
    }

    private var fallback: some View {
        ZStack {
            Color.dsSurface
            Image(systemName: "person.fill")
                .foregroundColor(.dsTextMuted)
                .font(.system(size: size * 0.45))
        }
    }
}
