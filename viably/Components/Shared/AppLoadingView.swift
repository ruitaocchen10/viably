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
                .opacity(pulse ? 1.0 : 0.4)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.2).repeatForever(autoreverses: true)) {
                        pulse = true
                    }
                }
        }
    }
}

#Preview {
    AppLoadingView()
}
