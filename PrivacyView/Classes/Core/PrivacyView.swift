import SwiftUI

public struct PrivacyView<Content: View>: View {
    private let configuration: PrivacyConfiguration
    private let content: Content
    @StateObject private var coordinator: PrivacyEngineCoordinator
    @Environment(\.scenePhase) private var scenePhase
    
    public init(
        configuration: PrivacyConfiguration = .default,
        controller: PrivacyController? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.configuration = configuration
        self.content = content()
        _coordinator = StateObject(wrappedValue: PrivacyEngineCoordinator(
            configuration: configuration,
            controller: controller
        ))
    }
    
    public var body: some View {
        ZStack {
            content
                .opacity(coordinator.state == .secure || coordinator.state == .paused ? 1 : 0)
                .accessibility(hidden: coordinator.state == .breached || coordinator.state == .unknown)
            
            if coordinator.state != .secure && coordinator.state != .paused {
                PrivacyOverlay(configuration: configuration, content: content)
                    .transition(.opacity)
            }
        }
        .animation(
            .easeInOut(duration: configuration.transitionDuration),
            value: coordinator.state
        )
        .onChange(of: scenePhase) { phase in
            coordinator.handleScenePhase(phase)
        }
        .onAppear {
            coordinator.start()
        }
        .onDisappear {
            coordinator.stop()
        }
    }
}
