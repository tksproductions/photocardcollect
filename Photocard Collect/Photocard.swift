struct Photocard: Identifiable, Codable {
    var id: UUID
    var imageName: String
    var isCollected: Bool
    var isWishlisted: Bool
    var name: String?
    
    var image: UIImage? {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
                .appendingPathComponent(imageName),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return UIImage(data: data)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        imageName = try container.decode(String.self, forKey: .imageName)
        isCollected = try container.decode(Bool.self, forKey: .isCollected)
        isWishlisted = try container.decode(Bool.self, forKey: .isWishlisted)
        name = try container.decodeIfPresent(String.self, forKey: .name)
    }
    
}

extension Photocard {
    init(id: UUID = UUID(), image: UIImage, isCollected: Bool, isWishlisted: Bool = false, name: String = "") {
        self.id = id
        self.isCollected = isCollected
        self.isWishlisted = isWishlisted 
        self.name = name
        let imageName = UUID().uuidString + ".png"
        self.imageName = imageName
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent(imageName),
           let imageData = image.pngData() {
            try? imageData.write(to: url)
        }
    }
}
