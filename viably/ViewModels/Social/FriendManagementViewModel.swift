import Foundation
import Supabase
import Combine

@MainActor
final class FriendManagementViewModel: ObservableObject {
    @Published var pendingRequests: [Friendship] = []
    @Published var searchText: String = ""
    @Published var searchResults: [Profile] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var sentRequests: Set<UUID> = []

    private let userID: UUID

    init() {
        guard let id = supabase.auth.currentUser?.id else {
            preconditionFailure("FriendManagementViewModel initialized without authenticated user")
        }
        self.userID = id
    }

    func loadPendingRequests() async {
        do {
            pendingRequests = try await FriendService.fetchPendingRequests(userID: userID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func acceptRequest(_ friendship: Friendship) async {
        do {
            try await FriendService.acceptRequest(friendshipID: friendship.id)
            pendingRequests.removeAll { $0.id == friendship.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func declineRequest(_ friendship: Friendship) async {
        do {
            try await FriendService.removeFriend(friendshipID: friendship.id)
            pendingRequests.removeAll { $0.id == friendship.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func searchUsers() async {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = []
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            let friends = try await FriendService.fetchFriends(userID: userID)
            let friendIDs = Set(friends.flatMap { [$0.requesterID, $0.addresseeID] })
            let results = try await ProfileService.search(username: searchText)
            searchResults = results.filter { $0.id != userID && !friendIDs.contains($0.id) }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func sendRequest(to profileID: UUID) async {
        do {
            try await FriendService.sendRequest(from: userID, to: profileID)
            sentRequests.insert(profileID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
