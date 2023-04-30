import SwiftUI

struct PhotocardView: View {
    @Binding var photocard: Photocard

    var body: some View {
        Image(uiImage: photocard.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 165, height: 255)
            .opacity(photocard.isCollected ? 0.5 : 1)
            .onTapGesture {
                photocard.isCollected.toggle()
            }
    }
}
