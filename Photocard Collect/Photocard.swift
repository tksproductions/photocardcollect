import SwiftUI
import UIKit

struct Photocard: Identifiable, Codable {
    var id: UUID
    var imageName: String
    var isCollected: Bool
    
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
    init(id: UUID = UUID(), image: UIImage, isCollected: Bool) {
        self.id = id
        self.isCollected = isCollected
        
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
