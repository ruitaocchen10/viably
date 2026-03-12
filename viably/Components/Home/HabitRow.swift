import SwiftUI
import UIKit

struct LiquidBlobShape: Shape {
    var progress: CGFloat
    let fromLeft: Bool
    private let maxBulge: CGFloat = 20

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let w = (rect.width / 2) * progress
        let bulge = maxBulge * sin(progress * .pi)
        var path = Path()
        if fromLeft {
            let x = rect.minX + w
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: x, y: rect.minY))
            path.addCurve(
                to: CGPoint(x: x, y: rect.maxY),
                control1: CGPoint(x: x + bulge, y: rect.minY + rect.height * 0.35),
                control2: CGPoint(x: x + bulge, y: rect.maxY - rect.height * 0.35)
            )
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        } else {
            let x = rect.maxX - w
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: x, y: rect.minY))
            path.addCurve(
                to: CGPoint(x: x, y: rect.maxY),
                control1: CGPoint(x: x - bulge, y: rect.minY + rect.height * 0.35),
                control2: CGPoint(x: x - bulge, y: rect.maxY - rect.height * 0.35)
            )
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        }
        path.closeSubpath()
        return path
    }
}

struct HabitRow: View {
    let habit: Habit
    let isCompleted: Bool
    let onTap: () -> Void

    @State private var pressProgress: CGFloat = 0.0
    @State private var completionFlash: CGFloat = 0.0
    @State private var completionScale: CGFloat = 1.0
    @State private var streakBump: CGFloat = 1.0
    @State private var isAnimatingCompletion: Bool = false

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
            .scaleEffect(streakBump)
        }
        .padding(12)
        .background(
            ZStack {
                isCompleted ? Color(hex: "#162316") : Color.dsSurface
                LiquidBlobShape(progress: pressProgress, fromLeft: true)
                    .fill(Color.dsAccentLime.opacity(1.0))
                LiquidBlobShape(progress: pressProgress, fromLeft: false)
                    .fill(Color.dsAccentLime.opacity(1.0))
                Color.dsAccentLime.opacity(completionFlash)
            }
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .scaleEffect(completionScale)
        .onLongPressGesture(minimumDuration: 1.0, pressing: { isPressing in
            guard !isCompleted else { return }
            if !isPressing && isAnimatingCompletion { return }
            withAnimation(isPressing ? .linear(duration: 0.82) : .spring(duration: 0.2)) {
                pressProgress = isPressing ? 1.0 : 0.0
            }
        }, perform: {
            guard !isCompleted else { return }
            isAnimatingCompletion = true
            onTap()
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()

            // Flash in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.easeIn(duration: 0.12)) { completionFlash = 0.45 }
            }

            // Flash out + fade blobs + scale bounce
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.17) {
                withAnimation(.easeOut(duration: 0.28)) {
                    completionFlash = 0.0
                    pressProgress = 0.0
                }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    completionScale = 1.03
                }
            }

            // Return to rest
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.38) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    completionScale = 1.0
                }
                isAnimatingCompletion = false
            }
        })
        .onChange(of: habit.currentStreak) { oldValue, newValue in
            guard newValue > oldValue else { return }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { streakBump = 1.3 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.21) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { streakBump = 1.0 }
            }
        }
    }
}
