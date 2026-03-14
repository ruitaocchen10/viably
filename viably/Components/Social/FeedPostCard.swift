import SwiftUI

struct FeedPostCard: View {
    let post: Post
    let onHype: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: avatar + username + timestamp
            HStack(spacing: 12) {
                AvatarView(avatarURL: post.profile?.avatarURL, size: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text(post.profile?.displayName ?? post.profile?.username ?? "Friend")
                        .font(.dsSemiBoldLabel)
                        .foregroundColor(.dsTextPrimary)
                    Text(post.createdAt.relativeDescription)
                        .font(.dsCaption)
                        .foregroundColor(.dsTextMuted)
                }

                Spacer()
            }

            // Inner score card
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Viably Score")
                            .font(.dsCaption)
                            .foregroundColor(.dsTextMuted)
                        Text("\(post.score)")
                            .font(.dsXBoldTitle)
                            .foregroundColor(.dsAccentYellow)
                    }
                    Spacer()
                }

                if !post.completedHabits.isEmpty {
                    FlowLayout(spacing: 6) {
                        ForEach(post.completedHabits) { habit in
                            HabitTagBadge(name: habit.habitName, icon: habit.habitIcon)
                        }
                    }
                }
            }
            .padding(12)
            .background(Color.dsBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.dsBorder, lineWidth: 1)
            )

            // Caption
            if let caption = post.caption, !caption.isEmpty {
                Text(caption)
                    .font(.dsSemiBoldCaption)
                    .foregroundColor(.dsTextMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Actions
            HStack(spacing: 16) {
                Button(action: onHype) {
                    HStack(spacing: 6) {
                        Image(systemName: post.didHype ? "flame.fill" : "flame")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Hype \(post.hypeCount)")
                            .font(.dsSemiBoldCaption)
                    }
                    .foregroundColor(post.didHype ? .dsAccentOrange : .dsTextMuted)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        post.didHype
                            ? Color.dsAccentOrange.opacity(0.15)
                            : Color.dsSurface
                    )
                    .cornerRadius(20)
                }

                Button(action: {}) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Reply")
                            .font(.dsSemiBoldCaption)
                    }
                    .foregroundColor(.dsTextMuted)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.dsSurface)
                    .cornerRadius(20)
                }

                Spacer()
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

// MARK: - Avatar helper

private struct AvatarView: View {
    let avatarURL: String?
    let size: CGFloat

    var body: some View {
        Group {
            if let urlString = avatarURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.dsIconBackground
                }
            } else {
                Color.dsIconBackground
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.dsTextMuted)
                            .font(.system(size: size * 0.45))
                    )
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

// MARK: - Flow layout for wrapping habit pills

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }

        return CGSize(width: width, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - Date relative formatting

private extension Date {
    var relativeDescription: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: .now)
    }
}
