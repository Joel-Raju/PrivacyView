import AVFoundation

class CameraPermissionHandler {
    enum PermissionResult {
        case granted
        case denied
        case restricted
    }
    
    func requestIfNeeded() async -> PermissionResult {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return .granted
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            return granted ? .granted : .denied
        case .denied, .restricted:
            return .denied
        @unknown default:
            return .denied
        }
    }
}
