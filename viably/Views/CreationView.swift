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
    CreationView()
}
