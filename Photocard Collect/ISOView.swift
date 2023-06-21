import SwiftUI

struct ISOView: View {
    var photocards: [Photocard]
    var screenWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    var screenHeight = UIScreen.main.bounds.height

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        TabView {
            photocardView(isSquare: true)
                .tag(0)
            photocardView(isSquare: false)
                .tag(1)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }

    private func photocardView(isSquare: Bool) -> some View {
        GeometryReader { geometry in
            let frameHeight: CGFloat = isSquare ? geometry.size.width : min(geometry.size.width * 15 / 9, geometry.size.height)
            let (numColumns, imageWidth, imageHeight) = calculateGrid(screenWidth: geometry.size.width * 0.90, frameHeight: frameHeight * 0.90, numImages: photocards.count)
            
            if photocards.isEmpty {
                Text("No photocards in wishlist.")
                    .foregroundColor(.black)
                    .frame(width: geometry.size.width, height: frameHeight, alignment: .center)
                    .background(Color.black)
            } else {
                ZStack {
                    Color.black
                    
                    VStack {
                        Spacer()
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
                            .padding(.top, isSquare ? 2 : 12)
                        .background(Color.white)
                        Spacer()
                    }
                    .frame(width: geometry.size.width, height: frameHeight, alignment: .center)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.black)
    }

    private func calculateGrid(screenWidth: CGFloat, frameHeight: CGFloat, numImages: Int) -> (Int, CGFloat, CGFloat) {
        guard numImages > 0 else {
            return (0, screenWidth, frameHeight)
        }
        let ratio: CGFloat = 2 / 3
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
