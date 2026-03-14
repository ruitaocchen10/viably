//
//  AuthView.swift
//  viably
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        ZStack {
            Color.dsBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo / wordmark
                VStack(spacing: 8) {
                    Text("viablyy")
                        .font(.dsXBoldHeading)
                        .foregroundColor(.dsAccentLime)

                    Text("your habits. your streak. your day.")
                        .font(.dsCaption)
                        .foregroundColor(.dsTextMuted)
                }

                Spacer()

                // Sign-in buttons
                VStack(spacing: 8) {
                    if let error = authVM.errorMessage {
                        Text(error)
                            .font(.dsCaption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }

                    AuthButton(
                        label: "Sign in with Google",
                        icon: "globe",
                        isLoading: authVM.isLoading
                    ) {
                        Task { await authVM.signInWithGoogle() }
                    }

                }
                .padding(.horizontal, 16)
                .padding(.bottom, 48)
            }
        }
    }
}

private struct AuthButton: View {
    let label: String
    let icon: String
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                Text(label)
                    .font(.dsSemiBoldSectionLabel)
            }
            .foregroundColor(.dsTextPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.dsSurface)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.07), lineWidth: 1)
            )
            .cornerRadius(16)
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.6 : 1)
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}
