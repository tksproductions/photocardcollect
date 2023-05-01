import SwiftUI
import UIKit

struct PhotocardView: View {
    @Binding var photocard: Photocard
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Image(uiImage: photocard.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 165, height: 255)
            .opacity(photocard.isCollected ? 0.5 : 1)
            .border(colorScheme == .light ? Color.black : Color.white, width: 2)
            .onTapGesture {
                photocard.isCollected.toggle()
            }
    }
}
