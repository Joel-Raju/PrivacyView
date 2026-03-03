# PrivacyView

[![Version](https://img.shields.io/cocoapods/v/PrivacyView.svg?style=flat)](https://cocoapods.org/pods/PrivacyView)
[![License](https://img.shields.io/cocoapods/l/PrivacyView.svg?style=flat)](https://cocoapods.org/pods/PrivacyView)
[![Platform](https://img.shields.io/cocoapods/p/PrivacyView.svg?style=flat)](https://cocoapods.org/pods/PrivacyView)

> **Software analog of Samsung Galaxy S26 Ultra's "Flex Magic Pixel" Privacy Display.**  
> Any SwiftUI view wrapped in `PrivacyView` is visible to the direct viewer but replaced with a black overlay for shoulder-surfers detected by angle.

## Overview

PrivacyView replicates Samsung's hardware-level privacy display using two sensor approaches:

| Mode | Sensor | Permission | Works in Dark | Detects Multiple Viewers |
|---|---|---|---|---|
| `.gyroscope` | IMU accelerometer + gyro | None | Yes | No |
| `.arFace` | TrueDepth IR + dot projector | Camera | **Yes (IR)** | **Yes (up to 3)** |
| `.hybrid` | Both, camera as upgrade | Camera (optional) | Yes | Yes (when camera granted) |

**Platform:** iOS 16+  
**ARKit face tracking:** requires iPhone X or later (A11 Bionic chip minimum)  
**Swift version:** 5.9+

## Installation

PrivacyView is available through [CocoaPods](https://cocoapods.org). Add to your Podfile:

```ruby
# Full (gyroscope + ARFace)
pod 'PrivacyView'

# Core only — no camera permission needed
pod 'PrivacyView/Core'
```

Then run:
```bash
pod install
```

## Quick Start

### Basic Usage (Gyroscope)

```swift
import SwiftUI
import PrivacyView

struct ContentView: View {
    var body: some View {
        PrivacyView {
            Text("Sensitive content")
                .font(.largeTitle)
        }
    }
}
```

### ViewModifier Syntax

```swift
Text("My PIN: 1234")
    .privacyProtected()

// With custom configuration
Text("Banking info")
    .privacyProtected(configuration: .arFaceDefault)
```

### Advanced Configuration

```swift
PrivacyView(configuration: .init(
    engine: .arFace,
    sensitivityAngle: 25,
    overlay: .black,
    transitionDuration: 0.2,
    multiViewerDetection: true
)) {
    BankingDashboardView()
}
```

### Manual Pause/Resume

```swift
@StateObject private var privacy = PrivacyController()

var body: some View {
    VStack {
        PrivacyView(controller: privacy) {
            SensitiveView()
        }
        
        Button("Show screen for 10 seconds") {
            privacy.pause(for: 10)
        }
    }
}
```

## Configuration Options

### Engine Modes

- **`.gyroscope`** (default) — Uses device motion sensors, no permissions required
- **`.arFace`** — Uses TrueDepth camera for precise face tracking
- **`.hybrid`** — Starts with gyroscope, upgrades to ARFace if camera permission granted
- **`.disabled`** — Always shows content (useful for debugging)

### Preset Configurations

```swift
.default          // Gyroscope, 30° threshold
.arFaceDefault    // ARFace, 30°, multi-viewer detection
.maximum          // ARFace, 20°, instant cut, maximum security
.disabled         // Always shows content
```

### Overlay Styles

```swift
.black                      // Full opaque black (maximum privacy)
.blur(radius: 20)          // Blurs content in place
.custom(AnyView(...))      // Custom SwiftUI view
```

## Privacy & Permissions

### Camera Permission (ARFace/Hybrid only)

Add to your `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>PrivacyView uses the front camera to detect whether someone is looking at your screen from the side, in order to protect sensitive content.</string>
```

### Data Privacy

- Camera stream is **never stored, transmitted, or persisted**
- ARKit face anchors are processed in-memory only
- No PII is collected
- Package does not record video — only uses ARSession for face geometry

## How It Works

### Gyroscope Engine

Uses CoreMotion to detect device tilt. When the phone is tilted beyond the sensitivity angle (default 30°), content is hidden. Features:
- Auto-calibrates to user's natural holding angle
- 150ms debounce to prevent flicker
- Works in complete darkness
- Zero permissions required

### ARFace Engine

Uses TrueDepth camera (same hardware as Face ID) to track face position and angle. Features:
- Works in complete darkness (infrared)
- Detects up to 3 faces simultaneously
- Triggers breach if multiple viewers detected
- Sub-degree accuracy

### Hybrid Engine

Starts with gyroscope immediately, then requests camera permission. If granted, runs both engines in parallel. Content is hidden if **either** engine detects a breach.

## Example Project

To run the example project:

```bash
cd Example
pod install
open PrivacyView.xcworkspace
```

## Requirements

- iOS 16.0+
- Swift 5.9+
- Xcode 15.0+
- For ARFace: iPhone X or later with TrueDepth camera

## Known Limitations

- Multiple `PrivacyView` instances with `.arFace` mode will compete for camera access (v1.0)
- ARSession pauses during Face ID authentication prompts (recovers automatically)
- iPad support requires iPad Pro with TrueDepth (2018+)

## Author

Joel Raju  
joelraju@ymail.com

## License

PrivacyView is available under the MIT license. See the LICENSE file for more info.
