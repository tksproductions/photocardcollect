import SwiftUI
import UIKit

struct FolderView: View {
    @Binding private var folder: Folder
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
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
                ForEach(folder.photocards.indices, id: \.self) { index in
                    PhotocardView(photocard: $folder.photocards[index])
                        .contextMenu {
                            Button(action: {
                                folder.photocards.removeAll(where: { $0.id == $folder.photocards[index].id })
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
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
                // Add the selected image to the folder when the user dismisses the image picker
                if let selectedImage = selectedImage {
                    folder.photocards.append(Photocard(image: selectedImage, isCollected: false))
                }
            }) {
                // Present the image picker
                ImagePicker(selectedImage: $selectedImage)
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
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(selectedImage: $selectedImage)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        @Binding var selectedImage: UIImage?

        init(selectedImage: Binding<UIImage?>) {
            _selectedImage = selectedImage
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                selectedImage = image
            }
            picker.dismiss(animated: true, completion: nil)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}
