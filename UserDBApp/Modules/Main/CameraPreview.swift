import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    
    @ObservedObject var viewModel: CameraViewModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = viewModel.getPreviewLayer()
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
                previewLayer.frame = uiView.bounds
            }
        }
    }
}
