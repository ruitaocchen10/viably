//
//  DesignSystem.swift
//  viably
//

import SwiftUI

extension Color {
    static let dsBackground   = Color(hex: "#13131a")
    static let dsSurface      = Color(hex: "#1c1c28")
    static let dsAccentLime   = Color(hex: "#c8ff57")
    static let dsAccentPurple = Color(hex: "#7c6aff")
    static let dsAccentYellow = Color(hex: "#ffdb57")
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
    static let dsHeading      = Font.custom("Syne-ExtraBold", size: 28)
    static let dsSectionLabel = Font.custom("Syne-SemiBold", size: 16)
    static let dsCaption      = Font.custom("Syne-Medium", size: 12)
}
