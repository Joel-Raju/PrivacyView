import Foundation

class NullPrivacyEngine: PrivacyEngine {
    var name: String { "Null" }
    
    func start(stateHandler: @escaping (PrivacyState) -> Void) {
        Task { @MainActor in
            stateHandler(.secure)
        }
    }
    
    func stop() {}
}
