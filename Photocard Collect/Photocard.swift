import SwiftUI
import UIKit

struct Photocard: Identifiable, Codable {
    var id: UUID
    var image: Data
    var isCollected: Bool
}
extension Photocard {
    init(id: UUID = UUID(), image: UIImage, isCollected: Bool) {
        self.id = id
        self.image = image.pngData()!
        self.isCollected = isCollected
    }
    
    var uiImage: UIImage {
        return UIImage(data: image)!
    }
}
