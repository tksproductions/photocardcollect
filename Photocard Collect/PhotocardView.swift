import SwiftUI

struct PhotocardView: View {
    @Binding var photocard: Photocard
    @Environment(\.colorScheme) var colorScheme
    @State var showExpandedView = false
    @Binding var isSelected: Bool
    @Binding var isSelecting: Bool
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
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(colorScheme == .light ? Color.black : Color.white)
                    .frame(width: screenWidth - 20, height: (screenWidth-20) * 255/165)
                    .shadow(radius: 3)

                Image(uiImage: photocard.image ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .colorMultiply(photocard.isCollected ? Color.black.opacity(0.5) : .white) // darken the photocard image when collected
                    .overlay(isSelected ? Color(hex: "FF2E98").opacity(0.5) : Color.clear) // pink tint for selected photocard
                    .frame(width: screenWidth - 30, height: (screenWidth-30) * 255/165)
                    .clipShape(RoundedRectangle(cornerRadius: 10)) // Round the image corners
            }
        }
        .contextMenu {
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
    }
}
