import Foundation
import UIKit

class UserStorage: ObservableObject {
    
    func saveImageToDocuments(image: UIImage, fileName: String) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            do {
                try data.write(to: fileURL)
                return fileURL.path
            } catch {
                
            }
        }
        return nil
    }
    
    func isJPEG(url: URL) -> Bool
    { // TODO: wrong curly bracket place
        let jpegExtentions = ["jpg", "jpeg"]
        return jpegExtentions.contains(url.pathExtension.lowercased())
    }
}
