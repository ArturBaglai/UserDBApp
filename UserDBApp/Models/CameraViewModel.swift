import SwiftUI
import AVFoundation

import SwiftUI
import AVFoundation

class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    
    @Published var capturedImage: CapturedImage? = nil

    private let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private let previewLayer = AVCaptureVideoPreviewLayer() 

    private var cameraDevice: AVCaptureDevice?

    override init() {
        super.init()
        setupCamera()
    }

    private func setupCamera() {
        session.sessionPreset = .photo

        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            cameraDevice = device
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
            } catch {
                print("Error in camera setup: \(error.localizedDescription)")
            }

            if session.canAddOutput(output) {
                session.addOutput(output)
            }
        }
    }

    func startSession() {
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
    }

    func stopSession() {
        DispatchQueue.global(qos: .background).async {
            self.session.stopRunning()
        }
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        output.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Capture error: \(error.localizedDescription)")
            return
        }

        if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) {
            DispatchQueue.main.async {
                self.capturedImage = CapturedImage(image: image)
            }
        }
    }

    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        previewLayer.session = session
        previewLayer.videoGravity = .resizeAspectFill
        return previewLayer
    }
}
struct CapturedImage: Identifiable {
    var id: UUID = UUID()
    var image: UIImage
}
