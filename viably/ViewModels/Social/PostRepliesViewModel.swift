import Foundation
import Supabase
import Combine

@MainActor
final class PostRepliesViewModel: ObservableObject {
    @Published var replies: [Reply] = []
    @Published var isLoading = false
    @Published var isSending = false
    @Published var draftText = ""

    let postID: UUID
    let userID: UUID
    let onReplyAdded: () -> Void
    private var currentUserProfile: Profile?

    init(postID: UUID, onReplyAdded: @escaping () -> Void) {
        guard let id = supabase.auth.currentUser?.id else {
            preconditionFailure("PostRepliesViewModel initialized without authenticated user")
        }
        self.postID = postID
        self.userID = id
        self.onReplyAdded = onReplyAdded
    }

    func loadReplies() async {
        isLoading = true
        defer { isLoading = false }
        var fetched = (try? await ReplyService.fetchReplies(postID: postID)) ?? []
        guard !fetched.isEmpty else {
            replies = []
            return
        }
        let uniqueUserIDs = Array(Set(fetched.map { $0.userID }))
        let profiles: [Profile] = (try? await supabase
            .from("profiles")
            .select()
            .in("id", values: uniqueUserIDs)
            .execute()
            .value) ?? []
        let profileByID = Dictionary(uniqueKeysWithValues: profiles.map { ($0.id, $0) })
        currentUserProfile = profileByID[userID]
        for i in fetched.indices {
            fetched[i].profile = profileByID[fetched[i].userID]
        }
        replies = fetched
        if currentUserProfile == nil {
            currentUserProfile = try? await supabase
                .from("profiles")
                .select()
                .eq("id", value: userID)
                .single()
                .execute()
                .value
        }
    }

    func sendReply() async {
        let trimmed = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isSending else { return }
        isSending = true
        defer { isSending = false }

        // Optimistic update — clear field and show reply immediately
        draftText = ""
        let tempID = UUID()
        let optimistic = Reply(id: tempID, postID: postID, userID: userID,
                               content: trimmed, createdAt: .now, profile: currentUserProfile)
        replies.append(optimistic)
        onReplyAdded()

        do {
            var saved = try await ReplyService.createReply(userID: userID, postID: postID, content: trimmed)
            saved.profile = currentUserProfile
            // Swap temp reply for the real server reply
            if let idx = replies.firstIndex(where: { $0.id == tempID }) {
                replies[idx] = saved
            }
        } catch {
            // Rollback — remove optimistic reply and restore draft so user can retry
            replies.removeAll { $0.id == tempID }
            draftText = trimmed
        }
    }

    func deleteReply(_ reply: Reply) async {
        guard reply.userID == userID else { return }
        replies.removeAll { $0.id == reply.id }
        try? await ReplyService.deleteReply(reply.id)
    }
}
