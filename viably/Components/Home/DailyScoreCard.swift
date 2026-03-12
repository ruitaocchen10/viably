import SwiftUI

struct DailyScoreCard: View {
    let score: Int
    let maxScore: Int
    let isViableDay: Bool
    let progressFraction: Double
    let mvdHabitsRemaining: Int

    @State private var scoreBump: CGFloat = 1.0
    @State private var borderGlow: Double = 0
    @State private var showSparkles: Bool = false
    @State private var cardPulse: CGFloat = 1.0
    @State private var shimmerOffset: CGFloat = -1.0
    @State private var wasViableDay: Bool = false
    @State private var wasFullScore: Bool = false
    @State private var sparkleOffsets: [(CGFloat, CGFloat)] = []
    @State private var sparkleOpacities: [Double] = []
    @State private var borderColor: Color = .dsAccentPurple

    private var isFullScore: Bool { progressFraction >= 1.0 && maxScore > 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text("Daily Score")
                    .font(.dsSemiBoldLabel)
                    .foregroundColor(.dsTextMuted)
                Spacer()
                Text("\(score)/\(maxScore)")
                    .font(.dsXBoldHeading)
                    .foregroundColor(.dsAccentLime)
                    .scaleEffect(scoreBump)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)

                    // Fill
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(LinearGradient(
                                colors: [.dsAccentPurple, .dsAccentLime],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: max(0, geo.size.width * progressFraction), height: 8)

                        // Shimmer overlay — only while incomplete
                        if progressFraction > 0 && progressFraction < 1.0 {
                            let fillWidth = max(0, geo.size.width * progressFraction)
                            Capsule()
                                .fill(LinearGradient(
                                    stops: [
                                        .init(color: .clear, location: 0),
                                        .init(color: .white.opacity(0.35), location: 0.5),
                                        .init(color: .clear, location: 1),
                                    ],
                                    startPoint: UnitPoint(x: shimmerOffset, y: 0),
                                    endPoint: UnitPoint(x: shimmerOffset + 1, y: 0)
                                ))
                                .frame(width: fillWidth, height: 8)
                                .clipped()
                        }
                    }
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progressFraction)

                    // Glow dot at leading edge of fill
                    if progressFraction > 0 {
                        Circle()
                            .fill(Color.dsAccentLime)
                            .frame(width: 10, height: 10)
                            .blur(radius: 3)
                            .offset(x: max(0, geo.size.width * progressFraction - 5), y: 0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progressFraction)
                    }

                    // Sparkle overlay
                    if showSparkles {
                        let barCenterX = geo.size.width * progressFraction / 2
                        ForEach(0..<min(sparkleOffsets.count, sparkleOpacities.count), id: \.self) { i in
                            Text("✦")
                                .font(.system(size: 10))
                                .foregroundColor(isFullScore ? .dsAccentLime : .dsAccentPurple)
                                .opacity(sparkleOpacities[i])
                                .offset(
                                    x: barCenterX + sparkleOffsets[i].0,
                                    y: sparkleOffsets[i].1
                                )
                        }
                    }
                }
            }
            .frame(height: 8)
            .padding(.bottom, showSparkles ? 20 : 0)
            .animation(.easeOut(duration: 0.3), value: showSparkles)

            // Status line
            if isViableDay {
                Text("Minimum Viable Day achieved!")
                    .font(.dsCaption)
                    .foregroundColor(.dsAccentLime)
                    .transition(.scale(scale: 0.7).combined(with: .opacity))
            } else if mvdHabitsRemaining > 0 {
                HStack(spacing: 0) {
                    Text("\(mvdHabitsRemaining) habit\(mvdHabitsRemaining == 1 ? "" : "s") to reach ")
                        .font(.dsCaption)
                        .foregroundColor(.dsTextMuted)
                    Text("Minimum Viable Day")
                        .font(.dsCaption)
                        .bold()
                        .foregroundColor(.dsAccentLime)
                }
            } else {
                Text("Complete your habits to build your score")
                    .font(.dsCaption)
                    .foregroundColor(.dsTextMuted)
            }
        }
        .padding(16)
        .background(Color.dsSurface)
        .cornerRadius(16)
        .scaleEffect(cardPulse)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.dsBorder, lineWidth: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor, lineWidth: 2)
                .opacity(borderGlow)
        )
        .onAppear {
            wasViableDay = isViableDay
            wasFullScore = isFullScore
            startShimmer()
        }
        .onChange(of: score) { _ in
            animateScoreBump()
        }
        .onChange(of: isViableDay) { newValue in
            if newValue && !wasViableDay {
                triggerMVDCelebration()
            }
            wasViableDay = newValue
        }
        .onChange(of: progressFraction) { newValue in
            let newFullScore = newValue >= 1.0 && maxScore > 0
            if newFullScore && !wasFullScore {
                triggerFullScoreCelebration()
            }
            wasFullScore = newFullScore
        }
    }

    // MARK: - Animations

    private func animateScoreBump() {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
            scoreBump = 1.25
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                scoreBump = 1.0
            }
        }
    }

    private func triggerMVDCelebration() {
        borderColor = .dsAccentPurple
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        launchSparkles(intense: false)

        // Border pulse
        withAnimation(.easeIn(duration: 0.2)) { borderGlow = 0.8 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.4)) { borderGlow = 0 }
        }
    }

    private func triggerFullScoreCelebration() {
        borderColor = .dsAccentLime
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        launchSparkles(intense: true)

        // Double pulse border
        withAnimation(.easeIn(duration: 0.2)) { borderGlow = 0.8 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.easeOut(duration: 0.2)) { borderGlow = 0 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            withAnimation(.easeIn(duration: 0.2)) { borderGlow = 0.8 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 0.4)) { borderGlow = 0 }
        }

        // Card pulse
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { cardPulse = 1.015 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { cardPulse = 1.0 }
        }
    }

    private func launchSparkles(intense: Bool) {
        let count = intense ? 8 : 6
        let spread: CGFloat = intense ? 60 : 40

        sparkleOffsets = (0..<count).map { i in
            let angle = (CGFloat(i) / CGFloat(count)) * .pi * 2
            let radius = CGFloat.random(in: 10...spread)
            return (cos(angle) * radius, sin(angle) * radius - 20)
        }
        sparkleOpacities = Array(repeating: 1.0, count: count)
        showSparkles = true

        withAnimation(.easeOut(duration: 0.8)) {
            sparkleOpacities = Array(repeating: 0.0, count: count)
            sparkleOffsets = sparkleOffsets.map { ($0.0 * 2, $0.1 - 20) }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            showSparkles = false
        }
    }

    private func startShimmer() {
        guard progressFraction > 0 && progressFraction < 1.0 else { return }
        shimmerOffset = -1.0
        withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
            shimmerOffset = 1.5
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        DailyScoreCard(score: 11, maxScore: 24, isViableDay: false, progressFraction: 0.46, mvdHabitsRemaining: 2)
        DailyScoreCard(score: 24, maxScore: 24, isViableDay: true, progressFraction: 1.0, mvdHabitsRemaining: 0)
        DailyScoreCard(score: 0, maxScore: 0, isViableDay: false, progressFraction: 0, mvdHabitsRemaining: 0)
    }
    .padding()
    .background(Color.dsBackground)
}
