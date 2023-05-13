import SwiftUI

struct PhotocardView: View {
    @Binding var photocard: Photocard
    @Environment(\.colorScheme) var colorScheme
    @State var showExpandedView = false
    @Binding var isSelected: Bool
    @Binding var isSelecting: Bool
    var screenWidth = UIScreen.main.bounds.width

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(photocard.isCollected ? Color(hex: "FF2E98") : (photocard.isWishlisted ? Color(hex: "FFD700") : Color.white))
                .frame(width: 165, height: 255)
                .shadow(radius: 3)

            Image(uiImage: photocard.image ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 155, height: 245)
                .clipShape(RoundedRectangle(cornerRadius: 10)) // Round the image corners
        }
        .frame(width: 165, height: 255)
        .opacity(isSelected ? 0.5 : 1)
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
                    .fill(Color.white)
                    .frame(width: screenWidth - 20, height: (screenWidth-20) * 255/165)
                    .shadow(radius: 3)

                Image(uiImage: photocard.image ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: screenWidth - 30, height: (screenWidth-30) * 255/165)
                    .clipShape(RoundedRectangle(cornerRadius: 10)) // Round the image corners
            }
        }
        .contextMenu {
            Button(action: {
                photocard.isCollected.toggle()
                photocard.isWishlisted = false
            }) {
                Label(photocard.isCollected ? "Uncollect" : "Collect", systemImage: photocard.isCollected ? "minus.circle" : "plus.circle")
            }

            Button(action: {
                photocard.isWishlisted.toggle()
            }) {
                Label(photocard.isWishlisted ? "Remove from Wishlist" : "Add to Wishlist", systemImage: photocard.isWishlisted ? "star.slash" : "star")
            }
        }
    }
}
