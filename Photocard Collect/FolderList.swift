import SwiftUI
import UIKit
struct FolderList: View {
    @State private var showAddFolderSheet = false
    @State private var showImagePicker = false
    @State private var newFolderName = ""
    @State private var newFolderImage: UIImage?
    @State private var selectedFolder: Folder?
    @StateObject private var userData = UserData()
    @State private var editMode = false
    @Environment(\.colorScheme) var colorScheme
    @State private var showInstructionsPopover = false
    @State private var showFolderOrderingView = false
    var body: some View {
        ScrollView {
            if userData.folders.isEmpty {
                VStack (spacing:20) {
                        Text("No idols added")
                            .font(.title2)
                            .foregroundColor(colorScheme == .light ? Color.black : Color.white)
                            .padding(.top, UIScreen.main.bounds.width/2)

                        Button(action: {
                            showAddFolderSheet = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                    .foregroundColor(Color(hex: "FF2E98"))
                                Text("Add Idol")
                                    .foregroundColor(Color(hex: "FF2E98"))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                    ForEach(userData.folders.indices, id: \.self) { index in
                        
                        NavigationLink(destination: FolderView(folder: $userData.folders[index]).environmentObject(userData)) {
                            
                            VStack {
                                if let icon = userData.folders[index].icon {
                                    Image(uiImage: icon)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 175, height: 175)
                                        .border(colorScheme == .light ? Color.black : Color.white, width: 2)
                                        .clipped()
                                } else {
                                    Image(systemName: "folder")
                                        .frame(width: 175, height: 175)
                                        .contentShape(Rectangle())
                                        .border(colorScheme == .light ? Color.black : Color.white, width: 2)
                                }
                                Text(userData.folders[index].name)
                                    .foregroundColor(colorScheme == .light ? Color.black : Color.white)
                            }
                            .contextMenu {
                                Button(action: {
                                    // Set the selected folder to the current folder
                                    selectedFolder = userData.folders[index]
                                    // Show the sheet to edit the folder
                                    showAddFolderSheet = true
                                }) {
                                    Text("Edit")
                                    Image(systemName: "pencil")
                                }
                                Button(action: {
                                    // Remove the folder from the list
                                    userData.folders.removeAll(where: { $0.id == userData.folders[index].id })
                                    userData.saveFolders()
                                }) {
                                    Text("Delete")
                                    Image(systemName: "trash")
                                }
                            }
                        }
                    }

                }
            }
        }
        .padding(.top, 20)
        .frame(maxWidth: 800) // Limit the width
        .padding(.horizontal, 10) // Add a bit of padding
        .centered() // Create this extension
        
        .navigationTitle("Idols")
        .popover(isPresented: $showInstructionsPopover, arrowEdge: .top) {
            VStack(spacing: 16) {
                Text("Info")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 150)

                Divider()

                VStack(spacing: 12) {
                    InfoRow(symbolName: "circle", description: "Created by @beomgyulix")
                    InfoRow(symbolName: "circle", description: "Tap a photocard to enlarge")
                    InfoRow(symbolName: "circle", description: "Tap and hold a photocard/idol to modify")
                }
                .padding()

                Text("Icons")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                Divider()
                
                VStack(spacing: 12) {
                    InfoRow(symbolName: "sparkles", description: "Add photocards from a photocard template")
                    InfoRow(symbolName: "plus", description: "Add a photocard from an image of one")
                    InfoRow(symbolName: "magnifyingglass.circle", description: "Create a Wishlist/ISO image")
                }
                .padding()

                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .background(colorScheme == .light ? Color.white : Color.black)
            .cornerRadius(16)
            .padding()
        }


        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    showInstructionsPopover = true
                }) {
                    Image(systemName: "info.circle")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showFolderOrderingView = true
                }) {
                    Label("Reorder", systemImage: "list.bullet")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showAddFolderSheet = true
                }) {
                    Image(systemName: "plus")
                }
            }
            

        }

        .sheet(isPresented: $showFolderOrderingView) {
            FolderOrderingView(folders: $userData.folders)
        }

        
        .sheet(isPresented: $showAddFolderSheet) {
            NavigationView {
                Form {
                    Section(header: Text("Idol Name")) {
                        TextField("Enter a name", text: $newFolderName)
                    }
                    Section(header: Text("Idol Image")) {
                        if let image = newFolderImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 200)
                        }
                        Button(action: {
                            // Show the image picker when the user taps the select image button
                            showImagePicker = true
                        }) {
                            Text("Select Image")
                        }
                    }
                }
                
                .navigationBarTitle(selectedFolder == nil ? "New Idol" : "Edit Idol")
                .navigationBarItems(
                    leading: Button("Cancel") {
                        showAddFolderSheet = false
                        selectedFolder = nil
                    },
                    
                    trailing: Button(selectedFolder == nil ? "Save" : "Update") {
                        if newFolderName.isEmpty {
                            // Display an alert informing the user that a name is required to save the folder
                            let alert = UIAlertController(title: "Name Required", message: "Please enter a name for the folder.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first else { return }; window.rootViewController?.present(alert, animated: true, completion: nil)
                        } else if newFolderImage == nil {
                            // Display an alert informing the user that an image is required to save the folder
                            let alert = UIAlertController(title: "Image Required", message: "Please select an image for the folder.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first else { return }; window.rootViewController?.present(alert, animated: true, completion: nil)
                        } else if let folderIndex = userData.folders.firstIndex(where: { $0.id == selectedFolder?.id }) {
                            // Create a new folder with the entered name and icon
                            let updatedFolder = Folder(
                                name: newFolderName,
                                icon: newFolderImage!,
                                photocards: selectedFolder!.photocards
                            )
                            // Replace the old folder with the updated folder
                            userData.folders[folderIndex] = updatedFolder
                            showAddFolderSheet = false
                            selectedFolder = nil
                        } else {
                            // Create a new folder with the entered name and icon
                            let newFolder = Folder(name: newFolderName, icon: newFolderImage, photocards: [])
                            userData.folders.append(newFolder)
                            showAddFolderSheet = false
                            selectedFolder = nil
                        }
                    }
                    .disabled(newFolderName.isEmpty || newFolderImage == nil)
                )

                
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker2(selectedImage: $newFolderImage)
                }
                .onAppear {
                    // If a folder was selected, pre-populate the form with its data
                    if let folder = selectedFolder {
                        newFolderName = folder.name
                        newFolderImage = folder.icon
                    }
                }
                .onDisappear {
                    newFolderName = ""
                    newFolderImage = nil
                }
            }
        }
    }
    
}

struct ImagePicker2: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(binding: $selectedImage)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        @Binding var selectedImage: UIImage?

        init(binding: Binding<UIImage?>) {
            _selectedImage = binding
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

extension View {
    func centered() -> some View {
        HStack {
            Spacer()
            self
            Spacer()
        }
    }
}

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let backBarButtonItem = UIBarButtonItem(title: "You back button title here", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem
    }
}

struct InfoRow: View {
    let symbolName: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: symbolName)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "FF2E98"))

            Text(description)
                .font(.body)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                    
            Spacer()
        }
    }
}
