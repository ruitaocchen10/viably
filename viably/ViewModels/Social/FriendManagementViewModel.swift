import Foundation
import Supabase
import Combine

@MainActor
final class FriendManagementViewModel: ObservableObject {
    @Published var friends: [Profile] = []
    @Published var pendingRequests: [Friendship] = []
    @Published var requesterProfiles: [UUID: Profile] = [:]
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

    func loadFriends() async {
        do {
            let friendships = try await FriendService.fetchFriends(userID: userID)
            let otherIDs = friendships.map { $0.requesterID == userID ? $0.addresseeID : $0.requesterID }
            friends = await withTaskGroup(of: Profile?.self) { group in
                for id in otherIDs {
                    group.addTask { try? await ProfileService.fetch(id: id) }
                }
                var profiles: [Profile] = []
                for await result in group {
                    if let p = result { profiles.append(p) }
                }
                return profiles
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func removeFriend(_ profile: Profile) async {
        do {
            let friendships = try await FriendService.fetchFriends(userID: userID)
            guard let friendship = friendships.first(where: {
                $0.requesterID == profile.id || $0.addresseeID == profile.id
            }) else { return }
            try await FriendService.removeFriend(friendshipID: friendship.id)
            friends.removeAll { $0.id == profile.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadPendingRequests() async {
        do {
            let requests = try await FriendService.fetchPendingRequests(userID: userID)
            pendingRequests = requests
            await withTaskGroup(of: (UUID, Profile)?.self) { group in
                for friendship in requests {
                    group.addTask {
                        guard let profile = try? await ProfileService.fetch(id: friendship.requesterID) else { return nil }
                        return (friendship.requesterID, profile)
                    }
                }
                for await result in group {
                    if let (id, profile) = result {
                        requesterProfiles[id] = profile
                    }
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func acceptRequest(_ friendship: Friendship) async {
        do {
            try await FriendService.acceptRequest(friendshipID: friendship.id)
            pendingRequests.removeAll { $0.id == friendship.id }
            requesterProfiles.removeValue(forKey: friendship.requesterID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func declineRequest(_ friendship: Friendship) async {
        do {
            try await FriendService.removeFriend(friendshipID: friendship.id)
            pendingRequests.removeAll { $0.id == friendship.id }
            requesterProfiles.removeValue(forKey: friendship.requesterID)
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
