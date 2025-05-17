import SwiftUI
import PhotosUI

struct PhotoUploadView: View {
    
    @EnvironmentObject private var registrationViewModel: RegistrationViewModel
    @StateObject private var photoUploadViewModel: PhotoUploadViewModel
    @StateObject private var cameraViewModel = CameraViewModel()
    @State private var isShowingCameraView: Bool = false
    
    var userStorage: UserStorage
    
    init(userStorage: UserStorage, registrationViewModel: RegistrationViewModel) {
        self.userStorage = userStorage
        _photoUploadViewModel = StateObject(wrappedValue: PhotoUploadViewModel(registrationViewModel: registrationViewModel, userStorage: userStorage))
    }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Upload your photo")
                    .font(.subheadline)
                    .padding(23)
                Spacer()
                
                PhotosPicker(
                    selection: $photoUploadViewModel.selectedPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Text("Upload")
                        .foregroundColor(Color.secondaryApp)
                        .padding()
                }
                .onChange(of: photoUploadViewModel.selectedPhotoItem) { photoItem in
                    Task {
                        await photoUploadViewModel.choosePhoto(item: photoItem)
                    }
                }
                .buttonStyle(.plain)
            }
            .frame(width: 328, height: 56)
            .background(RoundedRectangle(cornerRadius: 3).stroke(borderColor(), lineWidth: 2))
            .padding(.horizontal)
            
            .actionSheet(isPresented: $photoUploadViewModel.isShowingActionSheet) {
                ActionSheet(
                    title: Text(""),
                    message: Text("Choose how you want to add a photo"),
                    buttons: [
                        .default(Text("Camera")) {
                            isShowingCameraView = true
                        },
                        .default(Text("Gallery")) {
                            
                        },
                        .cancel()
                    ]
                )
            }
            .sheet(isPresented: $isShowingCameraView) {
                CameraView(cameraViewModel: cameraViewModel) { capturedImage in
                    photoUploadViewModel.capturedPhoto = capturedImage.image
                    isShowingCameraView = false
                }
            }
            
            if let photoError = registrationViewModel.validationErrors["photo"]?.first {
                Text(photoError)
                    .font(.caption)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            }
        }
    }
    
    private func borderColor() -> Color {
        if registrationViewModel.didSubmit,
           let errors = registrationViewModel.validationErrors["photo"],
           !errors.isEmpty {
            return .red
        }
        return Color.uploadViewGray
    }
}
