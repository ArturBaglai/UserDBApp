import SwiftUI

struct CameraView: View {
    @ObservedObject var cameraViewModel: CameraViewModel
    var onCapture: (CapturedImage) -> Void
    
    var body: some View {
        ZStack {
            CameraPreview(viewModel: cameraViewModel)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        cameraViewModel.capturePhoto()
                    }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 50, height: 50)
                            .shadow(radius: 10)
                    }
                    Spacer()
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear() {
            cameraViewModel.startSession()
        }
        .onDisappear() {
            cameraViewModel.stopSession()
        }
        .onReceive(cameraViewModel.$capturedImage) { image in
            if let image = image {
                onCapture(image)
            }
            
        }
    }
}
struct ImageViewer: View {
    let image: UIImage
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 400)
                .cornerRadius(15)
            
            Button("Close") {
                UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
            }
            .padding()
        }
    }
}
