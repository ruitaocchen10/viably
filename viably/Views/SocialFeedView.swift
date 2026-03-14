import SwiftUI

struct SocialFeedView: View {
    @StateObject private var viewModel = SocialFeedViewModel()

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
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Friend Feed")
                                .font(.dsXBoldHeading)
                                .foregroundColor(.dsTextPrimary)
                            Text("See how your crew is doing")
                                .font(.dsSemiBoldCaption)
                                .foregroundColor(.dsTextMuted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                        .padding(.bottom, 16)

                        if viewModel.posts.isEmpty {
                            emptyState
                        } else {
                            ForEach(viewModel.posts) { post in
                                FeedPostCard(post: post) {
                                    Task { await viewModel.toggleHype(post: post) }
                                }
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
