import SwiftUI
import PrivacyView

struct ExampleContentView: View {
    @StateObject private var privacyController = PrivacyController()
    @State private var selectedEngine: PrivacyConfiguration.EngineMode = .gyroscope
    @State private var sensitivityAngle: Double = 30.0
    
    var body: some View {
        NavigationView {
            List {
                Section("Basic Examples") {
                    NavigationLink("Simple Privacy View") {
                        SimplePrivacyExample()
                    }
                    
                    NavigationLink("Banking Card Example") {
                        BankingCardExample()
                    }
                    
                    NavigationLink("PIN Entry Example") {
                        PINEntryExample()
                    }
                }
                
                Section("Advanced Examples") {
                    NavigationLink("Manual Control") {
                        ManualControlExample()
                    }
                    
                    NavigationLink("Custom Overlay") {
                        CustomOverlayExample()
                    }
                    
                    NavigationLink("ARFace Mode (Camera)") {
                        ARFaceExample()
                    }
                }
                
                Section("Configuration") {
                    Picker("Engine Mode", selection: $selectedEngine) {
                        Text("Gyroscope").tag(PrivacyConfiguration.EngineMode.gyroscope)
                        Text("ARFace").tag(PrivacyConfiguration.EngineMode.arFace)
                        Text("Hybrid").tag(PrivacyConfiguration.EngineMode.hybrid)
                        Text("Disabled").tag(PrivacyConfiguration.EngineMode.disabled)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Sensitivity: \(Int(sensitivityAngle))°")
                        Slider(value: $sensitivityAngle, in: 15...45, step: 5)
                    }
                }
            }
            .navigationTitle("PrivacyView Examples")
        }
    }
}

struct SimplePrivacyExample: View {
    var body: some View {
        PrivacyView {
            VStack(spacing: 20) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Sensitive Content")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("This content is protected from side viewers")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
        .navigationTitle("Simple Example")
    }
}

struct BankingCardExample: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("My Cards")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                PrivacyView(configuration: .init(
                    engine: .gyroscope,
                    sensitivityAngle: 25,
                    transitionDuration: 0.2
                )) {
                    CreditCardView(
                        cardNumber: "4532 1234 5678 9010",
                        cardHolder: "JOHN DOE",
                        expiryDate: "12/25",
                        cvv: "123"
                    )
                }
                .padding(.horizontal)
                
                Text("Public Information")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent Transactions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ForEach(0..<3) { _ in
                        HStack {
                            Image(systemName: "cart.fill")
                            Text("Purchase")
                            Spacer()
                            Text("$XX.XX")
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Banking Card")
    }
}

struct CreditCardView: View {
    let cardNumber: String
    let cardHolder: String
    let expiryDate: String
    let cvv: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "creditcard.fill")
                    .font(.title)
                Spacer()
                Text("VISA")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            Text(cardNumber)
                .font(.title3)
                .fontWeight(.semibold)
                .tracking(2)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("CARD HOLDER")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(cardHolder)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("EXPIRES")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(expiryDate)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading) {
                    Text("CVV")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(cvv)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding(25)
        .frame(height: 200)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .foregroundColor(.white)
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}

struct PINEntryExample: View {
    var body: some View {
        VStack(spacing: 40) {
            Text("Enter Your PIN")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("PIN: 1234")
                .font(.largeTitle)
                .fontWeight(.bold)
                .privacyProtected(configuration: .init(
                    sensitivityAngle: 30,
                    transitionDuration: 0.1
                ))
            
            Text("This PIN is protected using ViewModifier syntax")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .navigationTitle("PIN Entry")
    }
}

struct ManualControlExample: View {
    @StateObject private var controller = PrivacyController()
    
    var body: some View {
        VStack(spacing: 30) {
            PrivacyView(controller: controller) {
                VStack(spacing: 20) {
                    Image(systemName: "person.fill.viewfinder")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Confidential Meeting Notes")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(15)
            }
            .frame(height: 300)
            .padding()
            
            VStack(spacing: 15) {
                Button(action: {
                    controller.pause(for: 5)
                }) {
                    Label("Show for 5 seconds", systemImage: "eye.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    controller.pause(for: 10)
                }) {
                    Label("Show for 10 seconds", systemImage: "eye.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                if controller.isPaused {
                    Button(action: {
                        controller.resume()
                    }) {
                        Label("Hide Now", systemImage: "eye.slash.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Manual Control")
    }
}

struct CustomOverlayExample: View {
    var body: some View {
        PrivacyView(configuration: .init(
            overlay: .custom(AnyView(
                ZStack {
                    Color.black.opacity(0.95)
                    VStack(spacing: 20) {
                        Image(systemName: "eye.slash.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                        Text("Privacy Mode Active")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Content hidden from side viewers")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            ))
        )) {
            VStack(spacing: 20) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                
                Text("Private Document")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("This example uses a custom overlay view instead of the default black overlay.")
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
        .navigationTitle("Custom Overlay")
    }
}

struct ARFaceExample: View {
    var body: some View {
        PrivacyView(configuration: .arFaceDefault) {
            VStack(spacing: 30) {
                Image(systemName: "faceid")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("ARFace Mode")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 15) {
                    FeatureRow(icon: "camera.fill", text: "Uses TrueDepth camera")
                    FeatureRow(icon: "moon.fill", text: "Works in complete darkness")
                    FeatureRow(icon: "person.2.fill", text: "Detects multiple viewers")
                    FeatureRow(icon: "angle", text: "Sub-degree accuracy")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(15)
                
                Text("Requires camera permission")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("ARFace Mode")
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            Text(text)
        }
    }
}

#Preview {
    ExampleContentView()
}
