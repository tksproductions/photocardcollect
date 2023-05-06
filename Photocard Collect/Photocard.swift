import SwiftUI
import UIKit

struct Photocard: Identifiable {
    var id = UUID()
    var image: UIImage
    var isCollected: Bool
    
}
