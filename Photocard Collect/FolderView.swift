import SwiftUI
import UIKit
import PhotosUI
import CoreImage



struct FolderView: View {
    @EnvironmentObject private var userData: UserData
    @Binding private var folder: Folder
    @State private var showImagePicker = false
    @State private var selectedImages: [UIImage] = []
    @State private var showRenameAlert = false
    @State private var showTemplateImagePicker = false
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showTemplateImagePicker = true
                }) {
                    Image(systemName: "sparkles")
                        .foregroundColor(Color(hex: "FF2E98"))
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Show the image picker when the user taps the plus button
                    showImagePicker = true
                })
                {
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
            
            for selectedImage in selectedImages {
                let extractedPhotos = extractPhotos(inputImage: selectedImage)
                for photo in extractedPhotos {
                    folder.photocards.append(Photocard(image: photo, isCollected: false))
                }
            }
            selectedImages.removeAll()
        }) {
            ImagePicker(selectedImages: $selectedImages)
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

import Vision
func extractPhotos(inputImage: UIImage, aspectRatio: (CGFloat, CGFloat) = (5.5, 8.5), minSize: CGFloat = 50) -> [UIImage] {
    guard let cgImage = inputImage.cgImage else { return [] }
    
    let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    
    var extractedImages: [UIImage] = []
    
    let request = VNDetectRectanglesRequest(completionHandler: { (request, error) in
        if let error = error {
            print("Error during rectangle detection: \(error.localizedDescription)")
            return
        }
        
        guard let results = request.results as? [VNRectangleObservation] else { return }
        print(results.count)
        
        for (_, observation) in results.enumerated() {
            let width = observation.boundingBox.width * CGFloat(cgImage.width)
            let height = observation.boundingBox.height * CGFloat(cgImage.height)
            let ratio = width / height
            
            if aspectRatio.0 / aspectRatio.1 * 0.7 <= ratio && ratio <= aspectRatio.0 / aspectRatio.1 * 1.3 && width >= minSize && height >= minSize {
                let x = observation.boundingBox.minX * CGFloat(cgImage.width)
                let y = (1 - observation.boundingBox.maxY) * CGFloat(cgImage.height)
                
                let cropRect = CGRect(x: x, y: y, width: width, height: height)
                if let croppedImage = cgImage.cropping(to: cropRect) {
                    let uiImage = UIImage(cgImage: croppedImage)
                    extractedImages.append(uiImage)
                } else {
                    print("no")
                }
            }
        }
    })
    
    request.maximumObservations = 1000
    request.quadratureTolerance = 75
    request.minimumConfidence = 0.5
    request.minimumSize = 0.001
    request.minimumAspectRatio = 0.4
    request.maximumAspectRatio = 0.8
    
    
    do {
        try requestHandler.perform([request])
    } catch {
        print("Error performing request: \(error.localizedDescription)")
    }
    print(extractedImages.count)
    return extractedImages
}


