import SwiftUI
struct FolderList: View {
    @State private var folders: [Folder] = []
    @State private var showAddFolderSheet = false
    @State private var showImagePicker = false
    @State private var newFolderName = ""
    @State private var newFolderImage: UIImage?
    @State private var selectedFolder: Folder?
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                ForEach(folders) { folder in
                    NavigationLink(destination: FolderView(folder: folder)) {
                        VStack {
                            if let icon = folder.icon {
                                Image(uiImage: icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                            } else {
                                Image(systemName: "folder")
                                    .frame(width: 100, height: 100)
                            }
                            Text(folder.name)
                        }
                        .contextMenu {
                            Button(action: {
                                // Set the selected folder to the current folder
                                selectedFolder = folder
                                // Show the sheet to edit the folder
                                showAddFolderSheet = true
                            }) {
                                Text("Edit")
                                Image(systemName: "pencil")
                            }
                            Button(action: {
                                // Remove the folder from the list
                                folders.removeAll(where: { $0.id == folder.id })
                            }) {
                                Text("Delete")
                                Image(systemName: "trash")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Photocard Collection")
        .navigationBarItems(trailing: Button(action: {
            showAddFolderSheet = true
        }) {
            Image(systemName: "plus")
        })
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
                        if let folderIndex = folders.firstIndex(where: { $0.id == selectedFolder?.id }) {
                            // Create a new folder with the entered name and icon
                            let updatedFolder = Folder(
                                name: newFolderName.isEmpty ? selectedFolder!.name : newFolderName,
                                icon: newFolderImage ?? selectedFolder!.icon,
                                photocards: selectedFolder!.photocards
                            )
                            // Replace the old folder with the updated folder
                            folders[folderIndex] = updatedFolder
                        } else {
                            // Create a new folder with the entered name and icon
                            let newFolder = Folder(name: newFolderName, icon: newFolderImage, photocards: [])
                            folders.append(newFolder)
                        }
                        showAddFolderSheet = false
                        selectedFolder = nil
                    }
                    .disabled(selectedFolder == nil && newFolderName.isEmpty)
                )
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(selectedImage: $newFolderImage)
                }
                .onAppear {
                    // If a folder was selected, pre-populate the form with its data
                    if let folder = selectedFolder {
                        newFolderName = folder.name
                        newFolderImage = folder.icon
                    }
                }
            }
        }
    }
}
