import Foundation
import ARKit
import simd

class ARFacePrivacyEngine: NSObject, PrivacyEngine, ARSessionDelegate {
    var name: String { "ARFace" }
    
    private let session = ARSession()
    private var stateHandler: ((PrivacyState) -> Void)?
    private var sensitivityAngle: Double = 30.0
    private var multiViewerDetection: Bool = true
    private var noFacePolicy: PrivacyConfiguration.NoFacePolicy = .showOverlay
    
    init(
        sensitivityAngle: Double = 30.0,
        multiViewerDetection: Bool = true,
        noFacePolicy: PrivacyConfiguration.NoFacePolicy = .showOverlay
    ) {
        self.sensitivityAngle = sensitivityAngle
        self.multiViewerDetection = multiViewerDetection
        self.noFacePolicy = noFacePolicy
        super.init()
    }
    
    func start(stateHandler: @escaping (PrivacyState) -> Void) {
        guard ARFaceTrackingConfiguration.isSupported else {
            Task { @MainActor in
                stateHandler(.unknown)
            }
            return
        }
        
        self.stateHandler = stateHandler
        session.delegate = self
        
        let configuration = ARFaceTrackingConfiguration()
        configuration.maximumNumberOfTrackedFaces = 3
        configuration.isLightEstimationEnabled = false
        
        session.run(configuration)
    }
    
    func stop() {
        session.pause()
        stateHandler = nil
    }
    
    func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .background, .inactive:
            session.pause()
            Task { @MainActor in
                self.stateHandler?(.unknown)
            }
        case .active:
            if let configuration = session.configuration {
                session.run(configuration)
            }
        @unknown default:
            break
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        let faceAnchors = anchors.compactMap { $0 as? ARFaceAnchor }
                                 .filter { $0.isTracked }
        
        if multiViewerDetection && faceAnchors.count > 1 {
            Task { @MainActor in
                self.stateHandler?(.breached)
            }
            return
        }
        
        if let primaryFace = faceAnchors.first {
            let angle = yawAngle(from: primaryFace)
            if angle > Float(sensitivityAngle) {
                Task { @MainActor in
                    self.stateHandler?(.breached)
                }
            } else {
                Task { @MainActor in
                    self.stateHandler?(.secure)
                }
            }
        } else {
            let state: PrivacyState = noFacePolicy == .showOverlay ? .unknown : .secure
            Task { @MainActor in
                self.stateHandler?(state)
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        Task { @MainActor in
            self.stateHandler?(.unknown)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self, let configuration = self.session.configuration else { return }
            self.session.run(configuration)
        }
    }
    
    private func yawAngle(from anchor: ARFaceAnchor) -> Float {
        let forwardVector = anchor.transform.columns.2
        let yaw = atan2(forwardVector.x, forwardVector.z)
        return abs(yaw) * (180 / .pi)
    }
}

import SwiftUI
