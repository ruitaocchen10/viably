//
//  AuthViewModel.swift
//  viably
//

import AuthenticationServices
import Combine
import SwiftUI
import Supabase

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        Task {
            await checkSession()
            await listenToAuthChanges()
        }
    }

    private func checkSession() async {
        do {
            _ = try await supabase.auth.session
            isAuthenticated = true
        } catch {
            isAuthenticated = false
        }
    }

    private func listenToAuthChanges() async {
        for await (event, session) in await supabase.auth.authStateChanges {
            switch event {
            case .signedIn:
                isAuthenticated = session != nil
            case .signedOut, .userDeleted:
                isAuthenticated = false
            default:
                break
            }
        }
    }

    func signInWithGoogle() async {
        await signIn(provider: .google)
    }

    private func signIn(provider: Provider) async {
        isLoading = true
        errorMessage = nil
        do {
            let context = WebAuthContext()
            try await supabase.auth.signInWithOAuth(
                provider: provider,
                redirectTo: URL(string: "com.ruitaochen.viably://auth/callback")
            ) { url in
                try await context.authenticate(url: url)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signOut() async {
        do {
            try await supabase.auth.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private class WebAuthContext: NSObject, ASWebAuthenticationPresentationContextProviding {
    private var session: ASWebAuthenticationSession?

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }

    func authenticate(url: URL) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let webSession = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: "com.ruitaochen.viably"
            ) { callbackURL, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let callbackURL {
                    continuation.resume(returning: callbackURL)
                } else {
                    continuation.resume(throwing: CancellationError())
                }
            }
            webSession.presentationContextProvider = self
            webSession.prefersEphemeralWebBrowserSession = true
            self.session = webSession
            webSession.start()
        }
    }
}
