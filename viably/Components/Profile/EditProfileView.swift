import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var photosItem: PhotosPickerItem?
    @State private var previewImage: Image?

    var body: some View {
        NavigationStack {
            Form {
                Section {
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
                }
                .listRowBackground(Color.clear)

                Section("Display Name") {
                    TextField("Display Name", text: $viewModel.editDisplayName)
                }

                Section("Username") {
                    HStack {
                        Text("@").foregroundColor(.dsTextMuted)
                        TextField("username", text: $viewModel.editUsername)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.save()
                            if viewModel.errorMessage == nil { dismiss() }
                        }
                    }
                    .disabled(viewModel.isLoading)
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
