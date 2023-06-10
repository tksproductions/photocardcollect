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
    @State private var showSnippetView = false
    @State private var newName = ""
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var sizeClass
    @State private var isSelecting = false
    @State private var selectedPhotocards = Set<UUID>()
    @State private var showISOView = false
    @State private var showActionSheet = false
    @State private var selectedRectangles: [HashableRect] = []
    @State private var selectedImageForSnippet: UIImage?
    @State private var showSnippetPicker = false

    
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
            folder.photocards.indices.sorted { index1, index2 in
                let card1 = folder.photocards[index1]
                let card2 = folder.photocards[index2]

                if card1.isWishlisted != card2.isWishlisted {
                    return card1.isWishlisted
                }

                if card1.isCollected != card2.isCollected {
                    return card1.isCollected == false && card2.isCollected == true
                }

                if let name1 = card1.name, let name2 = card2.name {
                    if name1.isEmpty && !name2.isEmpty {
                        return false
                    } else if !name1.isEmpty && name2.isEmpty {
                        return true
                    } else {
                        return name1 < name2
                    }
                } else if card1.name != nil {
                    return true
                } else {
                    return false
                }
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
                        VStack{
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
                                    withAnimation {
                                        folder.photocards.removeAll(where: { $0.id == folder.photocards[index].id })
                                        userData.saveFolders()
                                    }
                                }
                            )
                            ZStack {
                                Spacer()
                                    .frame(height: 20)
                                if let name = folder.photocards[index].name, !name.isEmpty {
                                    Text(name)
                                        .foregroundColor(colorScheme == .light ? Color.black : Color.white)
                                } else {
                                    Text(" ")
                                        .font(.headline)
                                }
                            }
                        }
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
                }
                else {
                    Button(action: {
                        showActionSheet = true
                    }) {
                        // Chose the "square.grid.2x2" as the icon for the button. Feel free to change it
                        Image(systemName: "square.grid.2x2")
                            .foregroundColor(Color(hex: "FF2E98"))
                    }
                    .actionSheet(isPresented: $showActionSheet) {
                        ActionSheet(
                            title: Text("Convert Template"),
                            message: Text("Select how to add the photocards."),
                            buttons: [
                                .default(Text("Auto"), action: {
                                    showTemplateImagePicker = true
                                }),
                                .default(Text("Snippet"), action: {
                                    showSnippetView = true
                                }),
                                .cancel()
                            ]
                        )
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
        }
        
        .sheet(isPresented: $showTemplateImagePicker, onDismiss: {
            
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
        
        .sheet(isPresented: $showSnippetView, onDismiss: {
            if let selectedImageForSnippet = selectedImageForSnippet {
                showSnippetPicker = true
            }
        }) {
            ImagePicker2(selectedImage: $selectedImageForSnippet)
        }
        .sheet(isPresented: $showSnippetPicker) {
            SnippetPicker(selectedImage: $selectedImageForSnippet, selectedRectangles: $selectedRectangles, folder: $folder)
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

struct HashableRect: Hashable {
    var rect: CGRect

    static func == (lhs: HashableRect, rhs: HashableRect) -> Bool {
        return lhs.rect.origin.x == rhs.rect.origin.x &&
               lhs.rect.origin.y == rhs.rect.origin.y &&
               lhs.rect.size.width == rhs.rect.size.width &&
               lhs.rect.size.height == rhs.rect.size.height
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(rect.origin.x)
        hasher.combine(rect.origin.y)
        hasher.combine(rect.size.width)
        hasher.combine(rect.size.height)
    }
}

struct SnippetPicker: View {
    @Binding var selectedImage: UIImage?
    @Binding var selectedRectangles: [HashableRect]
    @State private var drawingRect = CGRect.zero
    @Binding var folder: Folder
    @Environment(\.presentationMode) var presentationMode
    @State private var geometrySize: CGSize = .zero
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Image(uiImage: selectedImage ?? UIImage())
                        .resizable()
                        .scaledToFit()
                    
                    ForEach(selectedRectangles, id: \.self) { hashableRect in
                        Rectangle()
                            .path(in: hashableRect.rect)
                            .stroke(Constants.primaryColor, lineWidth: 3)
                    }
                    
                    Rectangle()
                        .path(in: drawingRect)
                        .stroke(Constants.primaryColor, lineWidth: 3)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let startPoint = value.startLocation
                            let endPoint = value.location
                            
                            let minX = min(startPoint.x, endPoint.x)
                            let minY = min(startPoint.y, endPoint.y)
                            let maxX = max(startPoint.x, endPoint.x)
                            let maxY = max(startPoint.y, endPoint.y)
                            
                            drawingRect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
                        }
                        .onEnded { value in
                            selectedRectangles.append(HashableRect(rect: drawingRect))
                            drawingRect = CGRect.zero
                        }
                )
                .onAppear {
                    self.geometrySize = geometry.size
                    selectedRectangles = []
                }
            }
            .navigationBarTitle("Snippet Picker", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        if let image = selectedImage, !geometrySize.equalTo(CGSize.zero) {
                            for selectedRect in selectedRectangles {
                                let convertedRect = convertToImageCoordinates(rect: selectedRect.rect, imageSize: image.size, viewSize: self.geometrySize)
                                if convertedRect.width > 0, convertedRect.height > 0, let croppedImage = cropImage(image: image, toRect: convertedRect) {
                                    folder.photocards.append(Photocard(image: croppedImage, isCollected: false))
                                }
                            }
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    func convertToImageCoordinates(rect: CGRect, imageSize: CGSize, viewSize: CGSize) -> CGRect {
        // Calculate the scaling factor and the image's position within the view
        let scale: CGFloat
        let xOffset: CGFloat
        let yOffset: CGFloat

        if imageSize.width / imageSize.height > viewSize.width / viewSize.height {
            scale = viewSize.width / imageSize.width
            xOffset = 0
            yOffset = (viewSize.height - imageSize.height * scale) / 2
        } else {
            scale = viewSize.height / imageSize.height
            xOffset = (viewSize.width - imageSize.width * scale) / 2
            yOffset = 0
        }

        let x = (rect.origin.x - xOffset) / scale
        let y = (rect.origin.y - yOffset) / scale
        let width = rect.size.width / scale
        let height = rect.size.height / scale
        return CGRect(x: x, y: y, width: width, height: height)
    }


    
    func cropImage(image: UIImage, toRect rect: CGRect) -> UIImage? {
        guard let cgImage = image.cgImage else {
            return nil
        }
        
        let contextImage: UIImage
        if image.imageOrientation != .up {
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            image.draw(in: CGRect(origin: .zero, size: image.size))
            contextImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
            UIGraphicsEndImageContext()
        } else {
            contextImage = image
        }
        
        if let croppedCGImage = cgImage.cropping(to: rect) {
            return UIImage(cgImage: croppedCGImage)
        }
        
        return nil
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
