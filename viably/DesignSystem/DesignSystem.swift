//
//  DesignSystem.swift
//  viably
//

import SwiftUI

extension Color {
    static let dsBackground   = Color(hex: "#13131a")
    static let dsSurface      = Color(hex: "#1c1c28")
    static let dsBorder       = Color.white.opacity(0.07)
    static let dsAccentLime   = Color(hex: "#c8ff57")
    static let dsAccentPurple = Color(hex: "#7c6aff")
    static let dsAccentYellow = Color(hex: "#ffdb57")
    static let dsAccentOrange = Color(hex: "#ff6b2b")
    static let dsTextPrimary  = Color(hex: "#ffffff")
    static let dsTextMuted    = Color(hex: "#6b6880")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension Font {
    static let dsXBoldHeading = Font.custom("Syne-ExtraBold", size: 32)
    static let dsXBoldTitle = Font.custom("Syne-ExtraBold", size: 24)
    static let dsXBoldSubtitle = Font.custom("Syne-ExtraBold", size: 20)

    static let dsBoldSubtitle = Font.custom("Syne-Bold", size: 20)
    static let dsBoldSectionLabel = Font.custom("Syne-Bold", size: 16)

    static let dsSemiBoldSectionLabel = Font.custom("Syne-SemiBold", size: 16)
    static let dsSemiBoldLabel = Font.custom("Syne-SemiBold", size: 14)
    static let dsSemiBoldCaption = Font.custom("Syne-SemiBold", size: 12)

    static let dsCaption = Font.custom("Syne-Medium", size: 12)
}
