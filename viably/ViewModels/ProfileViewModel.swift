import Foundation
import Combine
import Supabase

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var profile: Profile?
    @Published var bestStreak: Int = 0
    @Published var highScore: Int = 0
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Bindable edit fields — populated after fetch, written back on save
    @Published var editUsername: String = ""
    @Published var editDisplayName: String = ""
    @Published var pendingAvatarData: Data? = nil

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
            async let fetchedProfile = ProfileService.fetch(id: userID)
            async let fetchedHabits = HabitService.fetchAll(for: userID)
            async let fetchedHigh = DailyScoreService.fetchHighScore(for: userID)
            let (fetched, habits, high) = try await (fetchedProfile, fetchedHabits, fetchedHigh)
            profile = fetched
            editUsername = fetched.username
            editDisplayName = fetched.displayName ?? ""
            bestStreak = habits.map(\.currentStreak).max() ?? 0
            highScore = high
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func uploadAvatar(_ data: Data) async throws -> String {
        let path = "\(userID)/avatar.jpg"
        try await supabase.storage
            .from("avatars")
            .upload(path, data: data, options: FileOptions(contentType: "image/jpeg", upsert: true))
        let url = try supabase.storage.from("avatars").getPublicURL(path: path)
        return url.absoluteString
    }

    func save() async {
        guard let existing = profile else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            var newAvatarURL = existing.avatarURL
            if let data = pendingAvatarData {
                newAvatarURL = try await uploadAvatar(data)
                pendingAvatarData = nil
            }
            let updated = Profile(
                id: existing.id,
                username: editUsername,
                displayName: editDisplayName.isEmpty ? nil : editDisplayName,
                avatarURL: newAvatarURL,
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
