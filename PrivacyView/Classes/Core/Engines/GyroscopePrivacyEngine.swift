import Foundation
import CoreMotion

class GyroscopePrivacyEngine: PrivacyEngine {
    var name: String { "Gyroscope" }
    
    private let motionManager = CMMotionManager()
    private var baseline: CMAttitude?
    private var calibrationSamples: [CMAttitude] = []
    private var stateHandler: ((PrivacyState) -> Void)?
    private var breachTimer: Timer?
    private var sensitivityAngle: Double = 30.0
    private let debounceDelay: TimeInterval = 0.15
    
    init(sensitivityAngle: Double = 30.0) {
        self.sensitivityAngle = sensitivityAngle
    }
    
    func start(stateHandler: @escaping (PrivacyState) -> Void) {
        self.stateHandler = stateHandler
        baseline = nil
        calibrationSamples = []
        
        guard motionManager.isDeviceMotionAvailable else {
            Task { @MainActor in
                stateHandler(.unknown)
            }
            return
        }
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 30.0
        motionManager.startDeviceMotionUpdates(
            using: .xArbitraryZVertical,
            to: .main
        ) { [weak self] motion, error in
            guard let self, let motion else { return }
            self.process(motion)
        }
    }
    
    func stop() {
        motionManager.stopDeviceMotionUpdates()
        baseline = nil
        calibrationSamples = []
        breachTimer?.invalidate()
        breachTimer = nil
    }
    
    private func process(_ motion: CMDeviceMotion) {
        if baseline == nil {
            let rotationMagnitude = sqrt(
                pow(motion.rotationRate.x, 2) +
                pow(motion.rotationRate.y, 2) +
                pow(motion.rotationRate.z, 2)
            )
            
            if rotationMagnitude < 0.1 {
                calibrationSamples.append(motion.attitude)
            }
            
            if calibrationSamples.count >= 15 {
                baseline = calibrationSamples.last
            }
            
            Task { @MainActor in
                self.stateHandler?(.unknown)
            }
            return
        }
        
        let current = motion.attitude.copy() as! CMAttitude
        current.multiply(byInverseOf: baseline!)
        let rollDegrees = abs(current.roll) * (180 / .pi)
        
        if rollDegrees > sensitivityAngle {
            scheduleBreachAfterDebounce()
        } else {
            cancelBreachDebounce()
            Task { @MainActor in
                self.stateHandler?(.secure)
            }
        }
    }
    
    private func scheduleBreachAfterDebounce() {
        guard breachTimer == nil else { return }
        
        breachTimer = Timer.scheduledTimer(withTimeInterval: debounceDelay, repeats: false) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.stateHandler?(.breached)
            }
            self.breachTimer = nil
        }
    }
    
    private func cancelBreachDebounce() {
        breachTimer?.invalidate()
        breachTimer = nil
    }
}
