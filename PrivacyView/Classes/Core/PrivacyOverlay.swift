import SwiftUI

struct PrivacyOverlay<Content: View>: View {
    let configuration: PrivacyConfiguration
    let content: Content
    
    var body: some View {
        switch configuration.overlay {
        case .black:
            Color.black
        case .blur(let radius):
            content
                .blur(radius: radius)
                .allowsHitTesting(false)
        case .custom(let view):
            view
        }
    }
}
