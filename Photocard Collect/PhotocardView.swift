import SwiftUI

struct PhotocardView: View {
    @Binding var photocard: Photocard
    @Environment(\.colorScheme) var colorScheme
    @State var showExpandedView = false
    @Binding var isSelected: Bool
    @Binding var isSelecting: Bool
    @State var showEditNameDialog = false
    @State var newName = ""
    var screenWidth = UIScreen.main.bounds.width
    var deleteAction: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(photocard.isWishlisted ? Color(hex: "FF2E98") : (colorScheme == .light ? Color.black : Color.white))
                .frame(width: 165, height: 255)
                .shadow(radius: 3)
                .opacity(photocard.isCollected ? 0.5 : 1)
            
            Image(uiImage: photocard.image ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(photocard.isCollected ? Color(hex: "000000").opacity(0.5) : Color.clear)
                .overlay(isSelected ? Color(hex: "FF2E98").opacity(0.5) : Color.clear)
                .frame(width: 155, height: 245)
                .clipShape(RoundedRectangle(cornerRadius: 10)) // Round the image corners
            
        }
        
        .frame(width: 165, height: 255)
        .opacity(isSelected ? 0.5 : 1)
        .contentShape(RoundedRectangle(cornerRadius: 10)) // Apply the content shape
        .onTapGesture {
            if isSelecting {
                isSelected.toggle()
            } else {
                showExpandedView.toggle()
            }
        }
        
        .sheet(isPresented: $showExpandedView) {
            VStack {
                Text(photocard.name ?? "Unnamed Photocard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(colorScheme == .light ? Color.black : Color.white)
                        .frame(width: screenWidth - 20, height: (screenWidth-20) * 255/165)
                        .shadow(radius: 3)

                    Image(uiImage: photocard.image ?? UIImage())
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: screenWidth - 30, height: (screenWidth-30) * 255/165)
                        .clipShape(RoundedRectangle(cornerRadius: 10)) // Round the image corners
                }

                HStack(spacing: 20) {
                    Button(action: {
                        self.showExpandedView = false
                    }) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text("Close")
                        }
                    }
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .hoverEffect(.highlight)

                    Button(action: {
                        UIImageWriteToSavedPhotosAlbum(photocard.image ?? UIImage(), nil, nil, nil)
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Save")
                        }
                    }
                    .padding()
                    .background(Constants.primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .hoverEffect(.highlight)
                }
                .padding()
            }
            .padding()
        }



        .contextMenu {
            Button(action: {
                if let name = self.photocard.name {
                    self.newName = name
                } else {
                    self.newName = ""
                }
                self.showEditNameDialog = true
            }) {
                Label(photocard.name == "" ? "Add Name" : "Edit Name", systemImage: "pencil")
            }
            
            Button(action: {
                photocard.isCollected.toggle()
                photocard.isWishlisted = false
            }) {
                Label(photocard.isCollected ? "Remove from collected" : "Add to collected", systemImage: photocard.isCollected ? "minus.circle" : "plus.circle")
            }

            Button(action: {
                photocard.isWishlisted.toggle()
                photocard.isCollected = false
            }) {
                Label(photocard.isWishlisted ? "Remove from Wishlist" : "Add to Wishlist", systemImage: photocard.isWishlisted ? "star.slash" : "star")
            }

            Button(action: {
                deleteAction()
            }) {
                Label("Delete Photocard", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showEditNameDialog) {
            VStack(spacing: 20) {
                Text("Name Photocard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                TextField("Add a name", text: $newName)
                    .font(.title2)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding([.leading, .trailing])

                HStack(spacing: 20) {
                    Button(action: {
                        self.showEditNameDialog = false
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
                    .hoverEffect(.highlight)

                    Button(action: {
                        self.photocard.name = self.newName
                        self.showEditNameDialog = false
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save")
                        }
                    }
                    .padding()
                    .background(Constants.primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .hoverEffect(.highlight)
                }
            }
            .padding()
        }
    }
}
