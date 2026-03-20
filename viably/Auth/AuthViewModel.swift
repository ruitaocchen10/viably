//
//  AuthViewModel.swift
//  viably

import AuthenticationServices
import Combine
import CryptoKit
import SwiftUI
import Supabase

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUserID: UUID? = nil
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
                currentUserID = session?.user.id
            case .signedOut, .userDeleted:
                isAuthenticated = false
                currentUserID = nil
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

    func signInWithApple() async {
        isLoading = true
        errorMessage = nil
        let nonce = randomNonceString()
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        let controller = ASAuthorizationController(authorizationRequests: [request])
        let helper = AppleSignInHelper()
        controller.delegate = helper
        controller.presentationContextProvider = helper
        do {
            let authorization = try await withCheckedThrowingContinuation { continuation in
                helper.continuation = continuation
                controller.performRequests()
            }
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credential.identityToken,
                  let idToken = String(data: tokenData, encoding: .utf8) else {
                throw AuthError.missingCredential
            }
            try await AuthService.signInWithApple(idToken: idToken, nonce: nonce)
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

private class AppleSignInHelper: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    var continuation: CheckedContinuation<ASAuthorization, Error>?

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let scene = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first!
        return scene.keyWindow ?? UIWindow(windowScene: scene)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        continuation?.resume(returning: authorization)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
    }
}

private enum AuthError: LocalizedError {
    case missingCredential
    var errorDescription: String? { "Sign in failed. Please try again." }
}

private func randomNonceString(length: Int = 32) -> String {
    var randomBytes = [UInt8](repeating: 0, count: length)
    _ = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
    let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    return String(randomBytes.map { charset[Int($0) % charset.count] })
}

private func sha256(_ input: String) -> String {
    let data = Data(input.utf8)
    let hash = SHA256.hash(data: data)
    return hash.compactMap { String(format: "%02x", $0) }.joined()
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
