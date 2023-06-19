import SwiftUI
struct FolderOrderingView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @Binding var folders: [Folder]
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(folders, id: \.id) { folder in
                        HStack {
                            if let icon = folder.icon {
                                Image(uiImage: icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                Image(systemName: "folder")
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            
                            Text(folder.name)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                            
                            Spacer()
                        }
                        .padding(5)
                    }
                    .onMove(perform: move)
                    .listStyle(InsetListStyle())
                }
                
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Done")
                    }
                    .padding()
                    .background(Constants.primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .hoverEffect(.highlight)
                }
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Spacer()
                    }
                }
            }
            .navigationBarTitle("Reorder", displayMode: .inline)
            .environment(\.editMode, .constant(.active)) // make the list always in edit mode
            .focused($isFocused)
        }
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        folders.move(fromOffsets: source, toOffset: destination)
    }
}
