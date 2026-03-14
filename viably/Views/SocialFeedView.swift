import SwiftUI

struct SocialFeedView: View {
    @StateObject private var viewModel = SocialFeedViewModel()
    @State private var showFriendManagement = false
    @State private var replyingToPost: Post? = nil

    var body: some View {
        ZStack {
            Color.dsBackground.ignoresSafeArea()

            if viewModel.isLoading && viewModel.posts.isEmpty {
                ProgressView()
                    .tint(.dsAccentLime)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // Header
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Friend Feed")
                                    .font(.dsXBoldTitle)
                                    .foregroundColor(.dsTextPrimary)
                                Text("See how your crew is doing")
                                    .font(.dsSemiBoldLabel)
                                    .foregroundColor(.dsTextMuted)
                            }
                            Spacer()
                            Button { showFriendManagement = true } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color.dsAccentLime)
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "person.badge.plus")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.dsBackground)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                        .padding(.bottom, 16)

                        if viewModel.posts.isEmpty {
                            emptyState
                        } else {
                            ForEach(viewModel.posts) { post in
                                FeedPostCard(
                                    post: post,
                                    onHype: { Task { await viewModel.toggleHype(post: post) } },
                                    onReply: { replyingToPost = post }
                                )
                                .padding(.horizontal, 16)
                                .padding(.bottom, 12)
                            }
                        }

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.dsCaption)
                                .foregroundColor(.dsAccentOrange)
                                .padding(12)
                                .frame(maxWidth: .infinity)
                                .background(Color.dsSurface)
                                .cornerRadius(8)
                                .padding(.horizontal, 16)
                        }

                        Spacer(minLength: 32)
                    }
                }
                .refreshable { await viewModel.refresh() }
            }
        }
        .task { await viewModel.loadFeed() }
        .sheet(isPresented: $showFriendManagement) {
            FriendManagementView()
        }
        .sheet(item: $replyingToPost) { post in
            PostRepliesView(post: post) {
                viewModel.incrementReplyCount(for: post.id)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 48))
                .foregroundColor(.dsAccentLime)
            VStack(spacing: 6) {
                Text("No posts yet")
                    .font(.dsBoldSubtitle)
                    .foregroundColor(.dsTextPrimary)
                Text("Follow some friends to see their daily scores here.")
                    .font(.dsSemiBoldCaption)
                    .foregroundColor(.dsTextMuted)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .padding(.horizontal, 32)
    }
}

#Preview {
    SocialFeedView()
}
