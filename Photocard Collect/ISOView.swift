import SwiftUI

struct ISOView: View {
    var photocards: [Photocard]
    var screenWidth = UIScreen.main.bounds.width

    var body: some View {
        VStack {
            Text("ISO!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.top, 3)
                .padding(.bottom, 1)

            let (numColumns, numRows, imageWidth, imageHeight) = calculateGrid(screenWidth: screenWidth * 0.85, numImages: photocards.count)

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
                .padding(1)
            }
        }
        .frame(width: screenWidth, height: screenWidth)
        .background(Color.white)
    }

    private func calculateGrid(screenWidth: CGFloat, numImages: Int) -> (Int, Int, CGFloat, CGFloat) {
        let ratio: CGFloat = 2 / 3  // Aspect ratio of the images (2:3)
        let totalArea = screenWidth * screenWidth
        let imageArea = totalArea / CGFloat(numImages)
        var imageWidth = sqrt(imageArea * ratio)
        var imageHeight = imageWidth / ratio
        let numColumns = Int(floor(screenWidth / imageWidth))
        let numRows = Int(ceil(CGFloat(numImages) / CGFloat(numColumns)))
        // Adjust image height if it exceeds the available space
        let maxHeight = (screenWidth - CGFloat(numRows - 1) * 8) / CGFloat(numRows)
        if imageHeight > maxHeight {
            imageHeight = maxHeight
            imageWidth = imageHeight * ratio
        }

        return (numColumns, numRows, imageWidth, imageHeight)
    }
}
