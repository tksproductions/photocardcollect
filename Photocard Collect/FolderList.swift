import SwiftUI
import UIKit
struct FolderList: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var showAddFolderSheet = false
    @State private var showImagePicker = false
    @State private var showAuthView = false
    @State private var newFolderName = ""
    @State private var newFolderImage: UIImage?
    @State private var selectedFolder: Folder?
    @EnvironmentObject var userData: UserData
    @State private var editMode = false
    @Environment(\.colorScheme) var colorScheme
    @State private var showInstructionsPopover = false
    @State private var showFolderOrderingView = false
    @State private var selection = 0
    var body: some View {
        ScrollView {
            if userData.folders.isEmpty {
                VStack (spacing:20) {
                    if authService.isSignedIn {
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
                    else {
                        Text("Not Signed In")
                            .font(.title2)
                            .foregroundColor(colorScheme == .light ? Color.black : Color.white)
                            .padding(.top, UIScreen.main.bounds.width/2)
                        
                        Button(action: {
                            showAuthView = true
                        }) {
                            HStack {
                                Image(systemName: "person.circle")
                                    .foregroundColor(Color(hex: "FF2E98"))
                                Text("Sign In")
                                    .foregroundColor(Color(hex: "FF2E98"))
                            }
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
                                        .border(colorScheme == .light ? Color.black : Color.white, width: 4) // Increase border width
                                        .cornerRadius(5) // Rounded corners
                                        .clipped()
                                } else {
                                    Image(systemName: "folder")
                                        .frame(width: 175, height: 175)
                                        .contentShape(Rectangle())
                                        .border(colorScheme == .light ? Color.black : Color.white, width: 4) // Increase border width
                                        .cornerRadius(5) // Rounded corners
                                }
                                Text(userData.folders[index].name)
                                    .foregroundColor(colorScheme == .light ? Color.black : Color.white)
                            }
                            .contextMenu {
                                Button(action: {
                                    selectedFolder = userData.folders[index]
                                    showAddFolderSheet = true
                                }) {
                                    Text("Edit")
                                    Image(systemName: "pencil")
                                }
                                Button(action: {
                                    userData.folders.removeAll(where: { $0.id == userData.folders[index].id })
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
        .frame(maxWidth: 800)
        .padding(.horizontal, 10)
        .centered()
        
        .navigationTitle("Idols")
        .popover(isPresented: $showInstructionsPopover, arrowEdge: .top) {
            VStack(spacing: 16) {
                Text("Info")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 50)
                
                Divider()
                
                ScrollView {
                    VStack(spacing: 12) {
                        InfoRow(symbolName: "circle", description: "Created by @beomgyulix")
                        InfoRow(symbolName: "circle", description: "Tap a photocard to enlarge")
                        InfoRow(symbolName: "circle", description: "Tap and hold a photocard/idol to modify")
                    }
                    .padding()
                }
                
                Text("Icons")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                Divider()
                
                ScrollView {
                    VStack(spacing: 12) {
                        InfoRow(symbolName: "square.grid.2x2", description: "Add photocards from a photocard template")
                        InfoRow(symbolName: "plus", description: "Add a photocard from an image of one")
                        InfoRow(symbolName: "magnifyingglass.circle", description: "Create a Wishlist/ISO image")
                    }
                    .padding()
                }
                
                Text("Links")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                Divider()
                
                VStack(spacing: 12) {
                    Button(action: {
                        if let url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSea5-L7K-nmPBCGCao7IVgsG9VPmYV2CQHBG5FOtlVD1jOAIQ/viewform") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        InfoRow(symbolName: "exclamationmark.bubble", description: "Tell us how we can improve the app!")
                    }
                    
                    Button(action: {
                        if let url = URL(string: "https://www.buymeacoffee.com/pcollect") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        InfoRow(symbolName: "heart", description: "Help us fund our App Store license!")
                    }
                }
                
                Spacer()
                
            }
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
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
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    showAuthView = true
                }) {
                    Image(systemName: "person.circle")
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
        .sheet(isPresented: $showAuthView) {
            AuthenticationView()
        }
        .sheet(isPresented: $showAddFolderSheet) {
            NavigationView {
                VStack(spacing: 20) {
                    Text(selectedFolder == nil ? "New Idol" : "Edit Idol")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)

                    TextField("Enter a name", text: $newFolderName)
                        .font(.title2)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .padding([.leading, .trailing])

                    if let image = newFolderImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 175, height: 175)
                            .clipped()
                            .border(colorScheme == .light ? Color.black : Color.white, width: 4)
                            .cornerRadius(5)
                    }
                    
                    Button(action: {
                        showImagePicker = true
                    }) {
                        Text("Select Image")
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding([.leading, .trailing])

                    HStack(spacing: 20) {
                        Button(action: {
                            showAddFolderSheet = false
                            selectedFolder = nil
                        }) {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                Text("Cancel")
                            }
                        }
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(15)

                        Button(action: {
                            if newFolderName.isEmpty {
                                let alert = UIAlertController(title: "Name Required", message: "Please enter a name for the folder.", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default))
                                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first else { return }; window.rootViewController?.present(alert, animated: true, completion: nil)
                            } else if newFolderImage == nil {
                                let alert = UIAlertController(title: "Image Required", message: "Please select an image for the folder.", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default))
                                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first else { return }; window.rootViewController?.present(alert, animated: true, completion: nil)
                            } else if let folderIndex = userData.folders.firstIndex(where: { $0.id == selectedFolder?.id }) {
                                let updatedFolder = Folder(
                                    name: newFolderName,
                                    icon: newFolderImage!,
                                    photocards: selectedFolder!.photocards
                                )
                                userData.folders[folderIndex] = updatedFolder
                                showAddFolderSheet = false
                                selectedFolder = nil
                            } else {
                                let newFolder = Folder(name: newFolderName, icon: newFolderImage, photocards: [])
                                userData.folders.append(newFolder)
                                showAddFolderSheet = false
                                selectedFolder = nil
                                //userData.saveFolders()
                            }
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text(selectedFolder == nil ? "Save" : "Update")
                            }
                        }
                        .padding()
                        .background(newFolderName.isEmpty || newFolderImage == nil ? Color.gray : Constants.primaryColor)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .disabled(newFolderName.isEmpty || newFolderImage == nil)
                    }
                }
                .padding()
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
