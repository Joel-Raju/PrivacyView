import Foundation

public protocol PrivacyEngine: AnyObject {
    func start(stateHandler: @escaping (PrivacyState) -> Void)
    func stop()
    var name: String { get }
}

public enum PrivacyState: Equatable {
    case secure
    case breached
    case unknown
    case paused
}
