import SwiftUI

struct ISOView: View {
    var photocards: [Photocard]
    var screenWidth = min(UIScreen.main.bounds.width, 700)
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        TabView {
            photocardView(isSquare: true)
                .tag(0)
            photocardView(isSquare: false)
                .tag(1)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .padding(.bottom, 20)
    }
    
    private func photocardView(isSquare: Bool) -> some View {
        let frameHeight: CGFloat = isSquare ? screenWidth : screenWidth * 16 / 9
        return VStack {
            if photocards.isEmpty {
                Text("No photocards in wishlist.")
                    .foregroundColor(.black)
            } else {
                let (numColumns, imageWidth, imageHeight) = calculateGrid(screenWidth: screenWidth * 0.90, frameHeight: frameHeight * 0.90, numImages: photocards.count)
                
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: numColumns), spacing: 8) {
                        ForEach(photocards) { photocard in
                            if let image = photocard.image {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: imageWidth, height: imageHeight)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                                    .padding(0)
                            }
                        }
                    }
                    .padding(10)
                    .padding(.top, 15)
                }
                .disabled(true)
            }
        }
        .frame(width: screenWidth, height: frameHeight)
        .background(Color.white)
    }
    
    private func calculateGrid(screenWidth: CGFloat, frameHeight: CGFloat, numImages: Int) -> (Int, CGFloat, CGFloat) {
        let ratio: CGFloat = 2 / 3  // Aspect ratio of the images (2:3)
        let totalArea = screenWidth * frameHeight
        let imageArea = totalArea / CGFloat(numImages)
        var imageWidth = sqrt(imageArea * ratio)
        var imageHeight = imageWidth / ratio
        let numColumns: Int
        if numImages == 2 {
            numColumns = 2
        } else {
            numColumns = Int(floor(screenWidth / imageWidth))
        }
        let numRows = Int(ceil(CGFloat(numImages) / CGFloat(numColumns)))

        let maxHeight = (frameHeight - CGFloat(numRows - 1) * 8) / CGFloat(numRows)
        if imageHeight > maxHeight {
            imageHeight = maxHeight
            imageWidth = imageHeight * ratio
        }
        if numImages == 2 {
            imageWidth *= 4/5
            imageHeight *= 4/5
        }
        return (numColumns, imageWidth, imageHeight)
    }
}
