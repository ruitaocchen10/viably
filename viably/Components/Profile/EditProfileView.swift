import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var photosItem: PhotosPickerItem?
    @State private var previewImage: Image?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.dsBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        // Avatar picker
                        HStack {
                            Spacer()
                            PhotosPicker(selection: $photosItem, matching: .images) {
                                ZStack(alignment: .bottomTrailing) {
                                    avatarPreview
                                        .frame(width: 88, height: 88)
                                        .clipShape(Circle())
                                    Image(systemName: "camera.fill")
                                        .padding(6)
                                        .background(Color.dsAccentPurple)
                                        .clipShape(Circle())
                                        .foregroundColor(.white)
                                }
                            }
                            Spacer()
                        }

                        // Display Name field
                        fieldSection(label: "Display Name") {
                            TextField("Display Name", text: $viewModel.editDisplayName)
                                .font(.dsSemiBoldSectionLabel)
                                .foregroundColor(.dsTextPrimary)
                                .tint(.dsAccentLime)
                                .padding(14)
                                .background(Color.dsSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.dsBorder, lineWidth: 1)
                                )
                        }

                        // Username field
                        fieldSection(label: "Username") {
                            HStack {
                                Text("@")
                                    .font(.dsSemiBoldSectionLabel)
                                    .foregroundColor(.dsTextMuted)
                                TextField("username", text: $viewModel.editUsername)
                                    .font(.dsSemiBoldSectionLabel)
                                    .foregroundColor(.dsTextPrimary)
                                    .tint(.dsAccentLime)
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                            }
                            .padding(14)
                            .background(Color.dsSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.dsBorder, lineWidth: 1)
                            )
                        }

                        // Error message
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.dsCaption)
                                .foregroundColor(.red)
                        }

                        // Save CTA button
                        Button {
                            Task {
                                await viewModel.save()
                                if viewModel.errorMessage == nil { dismiss() }
                            }
                        } label: {
                            ZStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.dsBackground)
                                } else {
                                    Text("Save Changes")
                                        .font(.dsXBoldSubtitle)
                                        .foregroundColor(.dsBackground)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.dsAccentLime)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(viewModel.isLoading)
                    }
                    .padding(20)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.dsBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Edit Profile")
                        .font(.dsSemiBoldSectionLabel)
                        .foregroundColor(.dsTextPrimary)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(.dsSemiBoldLabel)
                        .foregroundColor(.dsTextMuted)
                }
            }
            .onChange(of: photosItem) { _, item in
                Task {
                    guard let item,
                          let data = try? await item.loadTransferable(type: Data.self) else { return }
                    viewModel.pendingAvatarData = data
                    if let uiImage = UIImage(data: data) {
                        previewImage = Image(uiImage: uiImage)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func fieldSection<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.dsSemiBoldLabel)
                .foregroundColor(.dsTextMuted)
            content()
        }
    }

    @ViewBuilder
    private var avatarPreview: some View {
        if let preview = previewImage {
            preview.resizable().scaledToFill()
        } else if let urlString = viewModel.profile?.avatarURL, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                if case .success(let img) = phase { img.resizable().scaledToFill() }
                else { fallback }
            }
        } else {
            fallback
        }
    }

    private var fallback: some View {
        ZStack {
            Circle().fill(Color.dsSurface)
            Image(systemName: "person.fill").font(.system(size: 36)).foregroundColor(.dsTextMuted)
        }
    }
}
