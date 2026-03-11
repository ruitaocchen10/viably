import Foundation
import Supabase

struct AuthService {
    static func authStateChanges() async -> AsyncStream<(AuthChangeEvent, Session?)> {
        await supabase.auth.authStateChanges
    }

    static func signIn(provider: Provider, redirectTo: URL, authenticate: (URL) async throws -> URL) async throws {
        try await supabase.auth.signInWithOAuth(provider: provider, redirectTo: redirectTo) { url in
            try await authenticate(url: url)
        }
    }

    static func signOut() async throws {
        try await supabase.auth.signOut()
    }
}
