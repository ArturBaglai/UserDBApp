import OSLog
import PhotosUI
import SwiftUI

class PhotoUploadViewModel: ObservableObject {

    @Published var isShowingActionSheet: Bool = false
    @Published var uploadedImage: UIImage?
    @Published var imageFileName: String = ""
    @Published var savedImagePath: String = ""
    @Published var photoError: String? = nil
    @Published var isShowingPhotoPicker: Bool = false
    @Published var capturedPhoto: UIImage?
    @Published var selectedPhotoItem: PhotosPickerItem? {
        didSet {
            if let photoItem = selectedPhotoItem {
                Task {
                    await choosePhoto(item: photoItem)
                }
            }
        }
    }

    var registrationViewModel: RegistrationViewModel
    var userStorage: UserStorage

    init(
        registrationViewModel: RegistrationViewModel,
        userStorage: UserStorage)
    {
        self.registrationViewModel = registrationViewModel
        self.userStorage = userStorage
    }

    @MainActor
    func choosePhoto(item: PhotosPickerItem?) async {
        guard let newItem = item else { return }

        do {
            if let data = try await newItem.loadTransferable(type: Data.self) {
                if let image = UIImage(data: data) {
                    let maxSizeInBytes = 5 * 1024 * 1024
                    if data.count > maxSizeInBytes {
                        registrationViewModel.validationErrors["photo"] = ["Image size more than 5 MB."]
                        return
                    }
                    registrationViewModel.photoData = data
                    uploadedImage = image
                    let fileName = "photo_\(UUID().uuidString).jpeg"
                    imageFileName = fileName
                    
                    if let savedPath = userStorage.saveImageToDocuments(image: image, fileName: fileName) {
                        self.savedImagePath = savedPath
                        
                        if !savedImagePath.isEmpty && userStorage.isJPEG(url: URL(fileURLWithPath: savedImagePath)) {
                            print("JPEG check passed, path: \(savedImagePath)")
                        } else {
                            print("Photo must be in JPEG format")
                        }
                    } else {
                        print("Failed to save image.")
                    }
                }
            }
        } catch {
            photoError = "Error loading or saving image: \(error)"
        }
    }
}
extension Logger {
    /// Using your bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!
    /// Logs the view cycles like a view that appeared.
    static let viewCycle = Logger(subsystem: subsystem, category: "viewcycle")
    /// All logs related to tracking and analytics.
    static let statistics = Logger(subsystem: subsystem, category: "statistics")
}
