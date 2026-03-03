import Foundation

class HybridPrivacyEngine: PrivacyEngine {
    var name: String { "Hybrid" }
    
    private let gyroscope: GyroscopePrivacyEngine
    private var arFace: ARFacePrivacyEngine?
    private var gyroState: PrivacyState = .unknown
    private var arState: PrivacyState = .unknown
    private var stateHandler: ((PrivacyState) -> Void)?
    
    init(
        sensitivityAngle: Double = 30.0,
        multiViewerDetection: Bool = true,
        noFacePolicy: PrivacyConfiguration.NoFacePolicy = .showOverlay
    ) {
        self.gyroscope = GyroscopePrivacyEngine(sensitivityAngle: sensitivityAngle)
        
        Task {
            let permission = await CameraPermissionHandler().requestIfNeeded()
            if permission == .granted {
                await MainActor.run {
                    let ar = ARFacePrivacyEngine(
                        sensitivityAngle: sensitivityAngle,
                        multiViewerDetection: multiViewerDetection,
                        noFacePolicy: noFacePolicy
                    )
                    self.arFace = ar
                    ar.start { [weak self] state in
                        self?.arState = state
                        self?.publishCombinedState()
                    }
                }
            }
        }
    }
    
    func start(stateHandler: @escaping (PrivacyState) -> Void) {
        self.stateHandler = stateHandler
        
        gyroscope.start { [weak self] state in
            self?.gyroState = state
            self?.publishCombinedState()
        }
    }
    
    func stop() {
        gyroscope.stop()
        arFace?.stop()
    }
    
    private func publishCombinedState() {
        let combined: PrivacyState
        
        if gyroState == .breached || arState == .breached {
            combined = .breached
        } else if gyroState == .secure && (arFace == nil || arState == .secure) {
            combined = .secure
        } else {
            combined = .unknown
        }
        
        Task { @MainActor in
            self.stateHandler?(combined)
        }
    }
}
