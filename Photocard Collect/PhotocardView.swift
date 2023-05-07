import SwiftUI

struct PhotocardView: View {
    @Binding var photocard: Photocard
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Image(uiImage: photocard.image ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 165, height: 255)
                .opacity(1)
                .border(photocard.isCollected ? Color(hex: "FF2E98") : (colorScheme == .light ? Color.black : Color.white), width: 2)
                .clipped()
            
            if photocard.isCollected {
                Color(hex: "FF2E98")
                    .opacity(0.25)
                    .frame(width: 165, height: 255)
                    .blendMode(.multiply)
            }
        }
        .frame(width: 165, height: 255)
        .contentShape(Rectangle()) // Add this line to limit the interactive area
        .onTapGesture {
            photocard.isCollected.toggle()
        }
    }
}
