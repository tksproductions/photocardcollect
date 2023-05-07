import SwiftUI
import UIKit
struct FolderList: View {
    @State private var showAddFolderSheet = false
    @State private var showImagePicker = false
    @State private var newFolderName = ""
    @State private var newFolderImage: UIImage?
    @State private var selectedFolder: Folder?
    @StateObject private var userData = UserData()
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                ForEach(userData.folders.indices, id: \.self) { index in
                    
                    NavigationLink(destination: FolderView(folder: $userData.folders[index]).environmentObject(userData)) {
                        // ...
                        VStack {
                            if let icon = userData.folders[index].iconImage {
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
                .padding(.top, 20) // add a padding to move the idols down
            }
        }
        .navigationTitle("Idols")
        
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showAddFolderSheet = true
                }) {
                    Image(systemName: "plus")
                }
            }
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

                .accentColor(Color(hex: "FF2E98"))
                
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(selectedImage: $newFolderImage)
                }
                .onAppear {
                    // If a folder was selected, pre-populate the form with its data
                    if let folder = selectedFolder {
                        newFolderName = folder.name
                        newFolderImage = folder.iconImage
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
