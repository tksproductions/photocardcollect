import SwiftUI
import UIKit

struct Folder: Identifiable, Codable {
    let id: UUID
    var name: String
    var iconImageName: String?
    var photocards: [Photocard]
    
    var icon: UIImage? {
        guard let imageName = iconImageName,
              let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
                .appendingPathComponent(imageName),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return UIImage(data: data)
    }
}

extension Folder {
    init(id: UUID = UUID(), name: String, icon: UIImage?, photocards: [Photocard]) {
        self.id = id
        self.name = name
        self.photocards = photocards
        
        // Save the icon image file to the document directory with a unique filename
        if let icon = icon {
            let imageName = UUID().uuidString + ".png"
            self.iconImageName = imageName
            if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
                .appendingPathComponent(imageName),
               let imageData = icon.pngData() {
                try? imageData.write(to: url)
            }
        }
    }
}
