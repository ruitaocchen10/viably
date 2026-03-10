//
//  SocialFeedView.swift
//  viably
//

import SwiftUI

struct SocialFeedView: View {
    var body: some View {
        ZStack {
            Color.dsBackground.ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.dsAccentLime)
                Text("Social Feed")
                    .font(.dsHeading)
                    .foregroundColor(.dsTextPrimary)
                Text("Coming Soon")
                    .font(.dsSectionLabel)
                    .foregroundColor(.dsTextMuted)
            }
        }
    }
}

#Preview {
    SocialFeedView()
}
