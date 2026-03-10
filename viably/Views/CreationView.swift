//
//  CreationView.swift
//  viably
//

import SwiftUI

struct CreationView: View {
    var body: some View {
        ZStack {
            Color.dsBackground.ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.dsAccentLime)
                Text("Create")
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
    CreationView()
}
