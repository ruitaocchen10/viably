import Foundation
import Supabase

struct AuthService {
    static func authStateChanges() -> AsyncStream<(event: AuthChangeEvent, session: Session?)> {
        supabase.auth.authStateChanges
    }

    static func signIn(provider: Provider, redirectTo: URL, authenticate: (URL) async throws -> URL) async throws {
        try await supabase.auth.signInWithOAuth(provider: provider, redirectTo: redirectTo) { url in
            try await authenticate(url)
        }
    }

    static func signInWithApple(idToken: String, nonce: String) async throws {
        try await supabase.auth.signInWithIdToken(
            credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
        )
    }

    static func signOut() async throws {
        try await supabase.auth.signOut()
    }

    static func deleteAccount(userID: UUID) async throws {
        // Best-effort avatar cleanup before deleting the user
        try? await supabase.storage.from("avatars").remove(paths: ["\(userID)/avatar.jpg"])
        try await supabase.rpc("delete_user").execute()
        try await supabase.auth.signOut(scope: .local)
    }
}
