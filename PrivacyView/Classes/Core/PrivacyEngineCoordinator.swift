import Foundation
import SwiftUI

@MainActor
class PrivacyEngineCoordinator: ObservableObject {
    @Published var state: PrivacyState = .unknown
    
    private var currentEngine: PrivacyEngine?
    private let configuration: PrivacyConfiguration
    private var controller: PrivacyController?
    
    init(configuration: PrivacyConfiguration, controller: PrivacyController? = nil) {
        self.configuration = configuration
        self.controller = controller
    }
    
    func start() {
        let engine = createEngine(for: configuration.engine)
        currentEngine = engine
        
        engine.start { [weak self] newState in
            Task { @MainActor in
                guard let self else { return }
                if let controller = self.controller, controller.isPaused {
                    self.state = .paused
                } else {
                    self.state = newState
                }
            }
        }
        
        if let controller = controller {
            observeController(controller)
        }
    }
    
    func stop() {
        currentEngine?.stop()
        currentEngine = nil
    }
    
    func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .background, .inactive:
            currentEngine?.stop()
            state = .unknown
        case .active:
            start()
        @unknown default:
            break
        }
    }
    
    private func createEngine(for mode: PrivacyConfiguration.EngineMode) -> PrivacyEngine {
        switch mode {
        case .gyroscope:
            return GyroscopePrivacyEngine(sensitivityAngle: configuration.sensitivityAngle)
        case .disabled:
            return NullPrivacyEngine()
        case .arFace:
            #if canImport(ARKit)
            return ARFacePrivacyEngine(
                sensitivityAngle: configuration.sensitivityAngle,
                multiViewerDetection: configuration.multiViewerDetection,
                noFacePolicy: configuration.noFacePolicy
            )
            #else
            return GyroscopePrivacyEngine(sensitivityAngle: configuration.sensitivityAngle)
            #endif
        case .hybrid:
            #if canImport(ARKit)
            return HybridPrivacyEngine(
                sensitivityAngle: configuration.sensitivityAngle,
                multiViewerDetection: configuration.multiViewerDetection,
                noFacePolicy: configuration.noFacePolicy
            )
            #else
            return GyroscopePrivacyEngine(sensitivityAngle: configuration.sensitivityAngle)
            #endif
        }
    }
    
    private func observeController(_ controller: PrivacyController) {
        controller.$isPaused.sink { [weak self] isPaused in
            Task { @MainActor in
                guard let self else { return }
                if isPaused {
                    self.state = .paused
                } else {
                    self.start()
                }
            }
        }.store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
}

import Combine
