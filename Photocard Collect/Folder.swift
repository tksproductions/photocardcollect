import SwiftUI
struct Folder: Identifiable {
    let id = UUID()
    var name: String
    var icon: UIImage?

    var photocards: [Photocard]
}
