import SwiftUI
import UIKit
struct Folder: Identifiable, Codable {
    let id: UUID
    var name: String
    var icon: Data?
    var photocards: [Photocard]
    
    enum CodingKeys: CodingKey {
        case id, name, icon, photocards
    }
    
    init(id: UUID = UUID(), name: String, icon: UIImage?, photocards: [Photocard]) {
        self.id = id
        self.name = name
        self.icon = icon?.pngData()
        self.photocards = photocards
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        icon = try container.decodeIfPresent(Data.self, forKey: .icon)
        photocards = try container.decode([Photocard].self, forKey: .photocards)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(icon, forKey: .icon)
        try container.encode(photocards, forKey: .photocards)
    }
    
    var iconImage: UIImage? {
        if let icon = icon {
            return UIImage(data: icon)
        }
        return nil
    }
}
