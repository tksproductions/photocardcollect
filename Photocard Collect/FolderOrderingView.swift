import SwiftUI

struct FolderOrderingView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var folders: [Folder]
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Idols")
                    .font(.headline)
                    .padding(.leading, 16)
                    .padding(.top, 16)
                
                Divider()
                
                List {
                    ForEach(folders, id: \.id) { folder in
                        HStack {
                            if let icon = folder.icon {
                                Image(uiImage: icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            } else {
                                Image(systemName: "folder")
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            }
                            Text(folder.name)
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                        }
                    }
                    .onMove(perform: move)
                }
                .listStyle(InsetListStyle())
                .navigationBarTitle("Reorder", displayMode: .inline)
                .navigationBarItems(
                    leading:
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Done")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                        }
                )
                .environment(\.editMode, .constant(.active)) // make the list always in edit mode
                .focused($isFocused)
                Spacer()
            }
        }
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        folders.move(fromOffsets: source, toOffset: destination)
    }
}
