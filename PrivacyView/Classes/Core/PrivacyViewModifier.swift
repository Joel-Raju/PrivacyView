import SwiftUI

public struct PrivacyViewModifier: ViewModifier {
    let configuration: PrivacyConfiguration
    let controller: PrivacyController?
    
    public init(configuration: PrivacyConfiguration = .default, controller: PrivacyController? = nil) {
        self.configuration = configuration
        self.controller = controller
    }
    
    public func body(content: Content) -> some View {
        PrivacyView(configuration: configuration, controller: controller) {
            content
        }
    }
}

public extension View {
    func privacyProtected(
        configuration: PrivacyConfiguration = .default,
        controller: PrivacyController? = nil
    ) -> some View {
        modifier(PrivacyViewModifier(configuration: configuration, controller: controller))
    }
}
