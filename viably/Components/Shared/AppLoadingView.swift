//
//  AppLoadingView.swift
//  viably
//

import SwiftUI

struct AppLoadingView: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            Color.dsBackground.ignoresSafeArea()
            Text("viablyy")
                .font(.dsXBoldHeading)
                .foregroundColor(.dsAccentLime)
                .scaleEffect(pulse ? 1.1 : 0.9)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                        pulse = true
                    }
                }
        }
    }
}

#Preview {
    AppLoadingView()
}
