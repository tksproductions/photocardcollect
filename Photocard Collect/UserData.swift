import SwiftUI
import UIKit

class UserData: ObservableObject {
    @Published var folders: [Folder] {
        didSet {
            saveFolders()
        }
    }
    
    init() {
        self.folders = Self.loadFolders()
    }
    
    private static let folderKey = "folders"
    
    public func saveFolders() {
        if let encodedFolders = try? JSONEncoder().encode(folders) {
            UserDefaults.standard.set(encodedFolders, forKey: Self.folderKey)
        }
    }
    
    private static func loadFolders() -> [Folder] {
        if let folderData = UserDefaults.standard.data(forKey: folderKey),
           let decodedFolders = try? JSONDecoder().decode([Folder].self, from: folderData) {
            return decodedFolders
        }
        return []
    }
}
