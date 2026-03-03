import SwiftUI

public struct PrivacyConfiguration {
    
    public enum EngineMode {
        case gyroscope
        case arFace
        case hybrid
        case disabled
    }
    
    public enum OverlayStyle {
        case black
        case blur(radius: CGFloat = 20)
        case custom(AnyView)
    }
    
    public enum NoFacePolicy {
        case showOverlay
        case showContent
    }
    
    public var engine: EngineMode
    public var sensitivityAngle: Double
    public var overlay: OverlayStyle
    public var transitionDuration: Double
    public var pauseOnUserRequest: Bool
    public var multiViewerDetection: Bool
    public var noFacePolicy: NoFacePolicy
    
    public init(
        engine: EngineMode = .gyroscope,
        sensitivityAngle: Double = 30.0,
        overlay: OverlayStyle = .black,
        transitionDuration: Double = 0.15,
        pauseOnUserRequest: Bool = true,
        multiViewerDetection: Bool = true,
        noFacePolicy: NoFacePolicy = .showOverlay
    ) {
        self.engine = engine
        self.sensitivityAngle = sensitivityAngle
        self.overlay = overlay
        self.transitionDuration = transitionDuration
        self.pauseOnUserRequest = pauseOnUserRequest
        self.multiViewerDetection = multiViewerDetection
        self.noFacePolicy = noFacePolicy
    }
    
    public static let `default` = PrivacyConfiguration()
    
    public static let arFaceDefault = PrivacyConfiguration(
        engine: .arFace,
        sensitivityAngle: 30,
        multiViewerDetection: true
    )
    
    public static let maximum = PrivacyConfiguration(
        engine: .arFace,
        sensitivityAngle: 20,
        overlay: .black,
        transitionDuration: 0,
        multiViewerDetection: true,
        noFacePolicy: .showOverlay
    )
    
    public static let disabled = PrivacyConfiguration(engine: .disabled)
}

extension PrivacyConfiguration.OverlayStyle: Equatable {
    public static func == (lhs: PrivacyConfiguration.OverlayStyle, rhs: PrivacyConfiguration.OverlayStyle) -> Bool {
        switch (lhs, rhs) {
        case (.black, .black):
            return true
        case (.blur(let r1), .blur(let r2)):
            return r1 == r2
        case (.custom, .custom):
            return true
        default:
            return false
        }
    }
}
