import Foundation
import Combine

public class PrivacyController: ObservableObject {
    @Published public private(set) var isPaused: Bool = false
    
    private var resumeTimer: Timer?
    
    public init() {}
    
    public func pause(for duration: TimeInterval) {
        isPaused = true
        resumeTimer?.invalidate()
        resumeTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.resume()
        }
    }
    
    public func resume() {
        isPaused = false
        resumeTimer?.invalidate()
        resumeTimer = nil
    }
    
    deinit {
        resumeTimer?.invalidate()
    }
}
