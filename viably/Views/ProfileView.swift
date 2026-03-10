//
//  ProfileView.swift
//  viably
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        ZStack {
            Color.dsBackground.ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "person.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.dsAccentLime)
                Text("Profile")
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
    ProfileView()
}
