import SwiftUI
import UIKit
import PhotosUI

struct FolderView: View {
    @EnvironmentObject private var userData: UserData
    @Binding private var folder: Folder
    @State private var showImagePicker = false
    @State private var selectedImages: [UIImage] = []
    @State private var showRenameAlert = false
    @State private var newName = ""
    @Environment(\.colorScheme) var colorScheme
    
    @available(iOS 15.0, *)
    var body: some View {
        var sortedPhotocards: [Int] {
            folder.photocards.indices.sorted { folder.photocards[$0].isCollected == false && folder.photocards[$1].isCollected == true }
        }
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                ForEach(sortedPhotocards, id: \.self) { index in
                    PhotocardView(photocard: $folder.photocards[index]).environmentObject(userData)
                        .contextMenu {
                            Button(action: {
                                folder.photocards.removeAll(where: { $0.id == $folder.photocards[index].id })
                                userData.saveFolders()
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
                .onMove(perform: move)
            }
            .padding()
        }
        .navigationTitle(folder.name + " Photocards")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button(action: {
                // Navigate back to the folder list view when the user taps the back button
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color(hex: "FF2E98"))
            },
            trailing: Button(action: {
                // Show the image picker when the user taps the plus button
                showImagePicker = true
            }) {
                Image(systemName: "plus")
                    .foregroundColor(Color(hex: "FF2E98"))
            }
            .sheet(isPresented: $showImagePicker, onDismiss: {
                for selectedImage in selectedImages {
                                    folder.photocards.append(Photocard(image: selectedImage, isCollected: false))
                                }
                                selectedImages.removeAll()
                            }) {
                                // Present the image picker
                                ImagePicker(selectedImages: $selectedImages)
                            }
        )
        .alert(isPresented: $showRenameAlert) {
            Alert(
                title: Text("Rename Idol"),
                message: Text("Enter a new name for the idol"),
                primaryButton: .default(Text("Rename"), action: {
                    folder.name = newName
                }),
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $showRenameAlert) {
            TextField("New Name", text: $newName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
        }
    }
    
    @Environment(\.presentationMode) var presentationMode

    init(folder: Binding<Folder>) {
        _folder = folder
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        folder.photocards.move(fromOffsets: source, toOffset: destination)
        userData.saveFolders()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(selectedImages: $selectedImages)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        @Binding var selectedImages: [UIImage]

        init(selectedImages: Binding<[UIImage]>) {
            _selectedImages = selectedImages
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true, completion: nil)
            
            let itemProviders = results.map(\.itemProvider)
            for itemProvider in itemProviders {
                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                        DispatchQueue.main.async {
                            if let image = image as? UIImage {
                                self?.selectedImages.append(image)
                            }
                        }
                    }
                }
            }
        }
    }
}
