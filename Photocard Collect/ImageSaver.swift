import SwiftUI
import Photos

class ImageSaver: ObservableObject {
    enum ImageSaverError: Error {
        case generalError
    }
    
    func saveImage(_ uiImage: UIImage?) {
        guard let uiImage = uiImage else {
            print("Error: Image is nil")
            return
        }
        let imageData = uiImage.jpegData(compressionQuality: 1.0)
        let compressedImage = UIImage(data: imageData!)
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: compressedImage!)
        }, completionHandler: { success, error in
            if success {
                print("Image successfully saved.")
            } else {
                print("Error occurred while saving image.")
            }
        })
    }
}
