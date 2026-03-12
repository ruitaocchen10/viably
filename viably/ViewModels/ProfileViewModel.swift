import Foundation
import Combine
import Supabase

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var profile: Profile?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Bindable edit fields — populated after fetch, written back on save
    @Published var editUsername: String = ""
    @Published var editDisplayName: String = ""

    private let userID: UUID

    init() {
        guard let id = supabase.auth.currentUser?.id else {
            preconditionFailure("ViewModel initialized without authenticated user")
        }
        self.userID = id
        Task { await loadProfile() }
    }

    func loadProfile() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let fetched = try await ProfileService.fetch(id: userID)
            profile = fetched
            editUsername = fetched.username
            editDisplayName = fetched.displayName ?? ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func save() async {
        guard let existing = profile else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let updated = Profile(
                id: existing.id,
                username: editUsername,
                displayName: editDisplayName.isEmpty ? nil : editDisplayName,
                avatarURL: existing.avatarURL,
                createdAt: existing.createdAt
            )
            profile = try await ProfileService.upsert(updated)
            editUsername = profile?.username ?? editUsername
            editDisplayName = profile?.displayName ?? ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
