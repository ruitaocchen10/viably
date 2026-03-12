//
//  AuthViewModel.swift
//  viably

import AuthenticationServices
import Combine
import SwiftUI
import Supabase

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var isCheckingSession = true
    @Published var errorMessage: String?

    private static let callbackURL = "com.ruitaochen.viably://auth/callback"
    private var authListenerTask: Task<Void, Never>?

    init() {
        authListenerTask = Task { await listenToAuthChanges() }
    }

    deinit {
        authListenerTask?.cancel()
    }

    private func listenToAuthChanges() async {
        for await (event, session) in AuthService.authStateChanges() {
            isCheckingSession = false
            switch event {
            case .initialSession, .signedIn:
                isAuthenticated = session != nil
            case .signedOut, .userDeleted:
                isAuthenticated = false
            default:
                break
            }
        }
    }

    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        do {
            guard let callbackURL = URL(string: Self.callbackURL) else {
                preconditionFailure("Invalid callback URL: \(Self.callbackURL)")
            }
            let context = WebAuthContext()
            try await AuthService.signIn(
                provider: .google,
                redirectTo: callbackURL
            ) { url in try await context.authenticate(url: url) }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signOut() async {
        isLoading = true
        do {
            try await AuthService.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

private class WebAuthContext: NSObject, ASWebAuthenticationPresentationContextProviding {
    private var session: ASWebAuthenticationSession?

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first!
        return scene.keyWindow ?? UIWindow(windowScene: scene)
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
