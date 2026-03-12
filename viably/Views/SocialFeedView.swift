//
//  SocialFeedView.swift
//  viably
//

import SwiftUI

struct SocialFeedView: View {
    var body: some View {
        ZStack {
            Color.dsBackground.ignoresSafeArea()
            VStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.dsAccentLime)
                Text("Social Feed")
                    .font(.dsXBoldHeading)
                    .foregroundColor(.dsTextPrimary)
                Text("Coming Soon")
                    .font(.dsSemiBoldSectionLabel)
                    .foregroundColor(.dsTextMuted)
            }
        }
    }
}

#Preview {
    SocialFeedView()
}
