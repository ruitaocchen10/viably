import SwiftUI

struct PostRepliesView: View {
    let post: Post
    let onReplyAdded: () -> Void
    let onBlockUser: (UUID) -> Void

    @StateObject private var viewModel: PostRepliesViewModel
    @FocusState private var isInputFocused: Bool
    @State private var reportingReply: Reply? = nil

    init(post: Post, onReplyAdded: @escaping () -> Void, onBlockUser: @escaping (UUID) -> Void = { _ in }) {
        self.post = post
        self.onReplyAdded = onReplyAdded
        self.onBlockUser = onBlockUser
        _viewModel = StateObject(wrappedValue: PostRepliesViewModel(postID: post.id, onReplyAdded: onReplyAdded))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.dsBorder)
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 12)

            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Replies")
                        .font(.dsBoldSubtitle)
                        .foregroundColor(.dsTextPrimary)
                    if let name = post.profile?.displayName ?? post.profile?.username {
                        Text("on \(name)'s post")
                            .font(.dsCaption)
                            .foregroundColor(.dsTextMuted)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)

            Divider()
                .background(Color.dsBorder)

            // Replies list
            if viewModel.isLoading && viewModel.replies.isEmpty {
                Spacer()
                ProgressView()
                    .tint(.dsAccentLime)
                Spacer()
            } else if viewModel.replies.isEmpty {
                Spacer()
                Text("No replies yet. Be the first!")
                    .font(.dsSemiBoldCaption)
                    .foregroundColor(.dsTextMuted)
                Spacer()
            } else {
                ScrollViewReader { proxy in
                    List {
                        ForEach(viewModel.replies) { reply in
                            ReplyRow(
                                reply: reply,
                                currentUserID: viewModel.userID,
                                onDelete: { Task { await viewModel.deleteReply(reply) } },
                                onReport: { reportingReply = reply },
                                onBlock: {
                                    Task { await viewModel.blockUser(reply.userID) }
                                    onBlockUser(reply.userID)
                                }
                            )
                            .id(reply.id)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets())
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .onAppear {
                        if let last = viewModel.replies.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                    .onChange(of: viewModel.replies.count) { _ in
                        if let last = viewModel.replies.last {
                            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                }
            }

            Divider()
                .background(Color.dsBorder)

            // Compose bar
            HStack(spacing: 10) {
                TextField("Write a reply…", text: $viewModel.draftText, axis: .vertical)
                    .font(.dsSemiBoldCaption)
                    .foregroundColor(.dsTextPrimary)
                    .lineLimit(1...4)
                    .focused($isInputFocused)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.dsSurface)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.dsBorder, lineWidth: 1)
                    )

                Button {
                    Task {
                        isInputFocused = false          // dismiss keyboard immediately
                        await viewModel.sendReply()     // optimistic update runs inside
                    }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(
                            viewModel.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isSending
                                ? Color.dsTextMuted
                                : Color.dsAccentLime
                        )
                }
                .disabled(viewModel.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isSending)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color.dsBackground)
        .task { await viewModel.loadReplies() }
        .sheet(item: $reportingReply) { reply in
            ReportContentView(target: .reply(reply), reporterID: viewModel.userID)
        }
    }
}

// MARK: - Reply Row

private struct ReplyRow: View {
    let reply: Reply
    let currentUserID: UUID
    let onDelete: () -> Void
    let onReport: () -> Void
    let onBlock: () -> Void

    @State private var showingBlockConfirm = false

    private var posterName: String { reply.profile.map { "@\($0.username)" } ?? "this user" }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            AvatarView(avatarURL: reply.profile?.avatarURL, size: 32)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(reply.profile?.displayName ?? reply.profile?.username ?? "Friend")
                        .font(.dsSemiBoldLabel)
                        .foregroundColor(.dsTextPrimary)
                    Text(reply.createdAt.replyRelativeDescription)
                        .font(.dsCaption)
                        .foregroundColor(.dsTextMuted)
                }
                Text(reply.content)
                    .font(.dsCaption)
                    .foregroundColor(.dsTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            if reply.userID == currentUserID {
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
                .tint(.red)
            }
        }
        .contextMenu {
            if reply.userID != currentUserID {
                Button(role: .destructive, action: onReport) {
                    Label("Report Reply", systemImage: "flag")
                }
                Button(role: .destructive) {
                    showingBlockConfirm = true
                } label: {
                    Label("Block \(posterName)", systemImage: "hand.raised")
                }
            }
        }
        .alert("Block \(posterName)?", isPresented: $showingBlockConfirm) {
            Button("Block", role: .destructive, action: onBlock)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You won't see their posts or replies. They won't be notified.")
        }
    }
}

// MARK: - Date formatting

private extension Date {
    var replyRelativeDescription: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: .now)
    }
}
