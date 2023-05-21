import SwiftUI
import UIKit
import PhotosUI
import CoreImage



struct FolderView: View {
    @EnvironmentObject private var userData: UserData
    @Binding private var folder: Folder
    @State private var showImagePicker = false
    @State private var selectedImages: [UIImage] = []
    @State private var selectedImage: UIImage?
    @State private var showRenameAlert = false
    @State private var showTemplateImagePicker = false
    @State private var newName = ""
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var sizeClass
    @State private var isSelecting = false
    @State private var selectedPhotocards = Set<UUID>()
    @State private var showISOView = false
    
    var wishlistedPhotocards: [Photocard] {
        folder.photocards.filter { $0.isWishlisted }
    }

    
    @available(iOS 15.0, *)
    
    var body: some View {
        
        var gridLayout: [GridItem] {
            switch sizeClass {
            case .compact:
                return [GridItem(.adaptive(minimum: 150))]
            default:
                return [GridItem(.adaptive(minimum: 200))]
            }
        }
        var sortedPhotocards: [Int] {
            folder.photocards.indices.sorted {
                if folder.photocards[$0].isWishlisted {
                    return true
                }
                if folder.photocards[$1].isWishlisted {
                    return false
                }
                return folder.photocards[$0].isCollected == false && folder.photocards[$1].isCollected == true
            }
        }

        ScrollView {
            if folder.photocards.isEmpty {
                VStack(spacing: 20) {
                    
                    Text("No photocards added")
                        .font(.title2)
                        .foregroundColor(colorScheme == .light ? Color.black : Color.white)
                        .padding(.top, UIScreen.main.bounds.width/2)
                    VStack {
                        Button(action: {
                            showImagePicker = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                    .foregroundColor(Color(hex: "FF2E98"))
                                Text("Add Photocard")
                                    .foregroundColor(Color(hex: "FF2E98"))
                            }
                        }
                    }
                    VStack {
                        Button(action: {
                            showTemplateImagePicker = true
                        }) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(Color(hex: "FF2E98"))
                                Text("Convert Template")
                                    .foregroundColor(Color(hex: "FF2E98"))
                            }
                        }
                    }
                    
                }
                .padding(.top, 50)
            }
            else {
                LazyVGrid(columns: gridLayout, spacing: 20) {
                    ForEach(sortedPhotocards, id: \.self) { index in
                        PhotocardView(
                            photocard: $folder.photocards[index],
                            isSelected: .init(get: {
                                
                                selectedPhotocards.contains(folder.photocards[index].id)
                            }, set: { newValue in
                                if newValue {
                                    selectedPhotocards.insert(folder.photocards[index].id)
                                } else {
                                    selectedPhotocards.remove(folder.photocards[index].id)
                                }
                            }),
                            isSelecting: $isSelecting,
                            deleteAction: {
                                folder.photocards.removeAll(where: { $0.id == folder.photocards[index].id })
                                userData.saveFolders()
                            }
                        )
                        
                    }
                    
                    .onMove(perform: move)
                }
                .padding(20)
                
            }
            
        }
        
        .navigationTitle(isSelecting ? "" : folder.name)
        .navigationBarTitleDisplayMode(.inline)
        
        .toolbar {
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if isSelecting {
                    Button(action: {
                        withAnimation {
                            for id in selectedPhotocards {
                                folder.photocards.removeAll(where: { $0.id == id })
                            }
                            userData.saveFolders()
                            selectedPhotocards.removeAll()
                            isSelecting.toggle()
                        }
                    }) {
                        Image(systemName: "trash")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if isSelecting {
                    Button(action: {
                        withAnimation {
                            for id in selectedPhotocards {
                                if let index = folder.photocards.firstIndex(where: { $0.id == id }) {
                                    folder.photocards[index].isWishlisted = !folder.photocards[index].isWishlisted
                                    if (folder.photocards[index].isWishlisted){
                                        folder.photocards[index].isCollected = false // Set isCollected to false
                                    }
                                }
                            }
                            userData.saveFolders()
                            selectedPhotocards.removeAll()
                            isSelecting.toggle() // Add this line to toggle isSelecting state
                        }
                    }) {
                        Image(systemName: "star")
                    }
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                if isSelecting {
                    Button(action: {
                        withAnimation {
                            for id in selectedPhotocards {
                                if let index = folder.photocards.firstIndex(where: { $0.id == id }) {
                                folder.photocards[index].isCollected = !folder.photocards[index].isCollected
                                    if (folder.photocards[index].isCollected){
                                        folder.photocards[index].isWishlisted = false
                                    }
                                }
                            }
                            userData.saveFolders()
                            selectedPhotocards.removeAll()
                            isSelecting.toggle()
                        }
                    }) {
                        Image(systemName: "plus.circle")
                    }
                }
            }

        
            ToolbarItem(placement: .navigationBarLeading) {
                if !isSelecting {
                    Button(action: {
                        showISOView = true
                    }) {
                        Image(systemName: "magnifyingglass.circle")
                    }
                    .sheet(isPresented: $showISOView) {
                        ISOView(photocards: wishlistedPhotocards)
                    }
                }
            }


            ToolbarItem(placement: .navigationBarTrailing) {
                if isSelecting {
                    Button(action: {
                        withAnimation {
                            isSelecting.toggle()
                            selectedPhotocards.removeAll()
                        }
                    }) {
                        Text("Cancel")
                    }
                } else {
                    Button(action: {
                        showTemplateImagePicker = true
                    }) {
                        Image(systemName: "sparkles")
                            .foregroundColor(Color(hex: "FF2E98"))
                    }
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                if !isSelecting {
                    Button(action: {
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
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                if !isSelecting {
                    Button(action: {
                        withAnimation {
                            isSelecting.toggle()
                            selectedPhotocards.removeAll()
                        }
                    }) {
                        Text("Select")
                    }
                }
            }
        }
        
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
    
        }   .sheet(isPresented: $showTemplateImagePicker, onDismiss: {
            
            if let selectedImage = selectedImage {
                if let extractedPhotos = extractPhotos(selectedImage) {
                    for photo in extractedPhotos {
                        folder.photocards.append(Photocard(image: photo, isCollected: false))
                    }
                }
            }
            selectedImages.removeAll()
        }) {
            ImagePicker2(selectedImage: $selectedImage)
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
