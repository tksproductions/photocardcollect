struct Photocard: Identifiable, Codable {
    var id: UUID
    var imageName: String
    var isCollected: Bool
    var isWishlisted: Bool  // New attribute for wishlist status
    
    var image: UIImage? {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
                .appendingPathComponent(imageName),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return UIImage(data: data)
    }
}

extension Photocard {
    init(id: UUID = UUID(), image: UIImage, isCollected: Bool, isWishlisted: Bool = false) {
        self.id = id
        self.isCollected = isCollected
        self.isWishlisted = isWishlisted  // Initialize the isWishlisted attribute
        
        // Save the image file to the document directory with a unique filename
        let imageName = UUID().uuidString + ".png"
        self.imageName = imageName
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent(imageName),
           let imageData = image.pngData() {
            try? imageData.write(to: url)
        }
    }
}
