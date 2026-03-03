#
# Be sure to run `pod lib lint PrivacyView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PrivacyView'
  s.version          = '1.0.0'
  s.summary          = 'SwiftUI privacy view — hides content from side viewers using gyroscope or TrueDepth camera.'

  s.description      = <<-DESC
Software analog of Samsung Galaxy S26 Ultra's Flex Magic Pixel Privacy Display.
Any SwiftUI view wrapped in PrivacyView is visible to the direct viewer but replaced 
with a black overlay for shoulder-surfers detected by angle using gyroscope or ARKit face tracking.
                       DESC

  s.homepage         = 'https://github.com/Joel-Raju/PrivacyView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Joel Raju' => 'joelraju@ymail.com' }
  s.source           = { :git => 'https://github.com/Joel-Raju/PrivacyView.git', :tag => s.version.to_s }

  s.ios.deployment_target = '16.0'
  s.swift_versions   = ['5.9']

  # Core subspec — gyroscope only, no ARKit dependency
  s.subspec 'Core' do |core|
    core.source_files = 'PrivacyView/Classes/Core/**/*.swift'
    core.frameworks   = 'CoreMotion', 'SwiftUI'
  end

  # Camera subspec — adds ARFaceAnchor engine
  s.subspec 'Camera' do |cam|
    cam.dependency 'PrivacyView/Core'
    cam.source_files = 'PrivacyView/Classes/Camera/**/*.swift'
    cam.frameworks   = 'ARKit', 'AVFoundation'
    cam.resource_bundles = {
      'PrivacyView' => ['PrivacyView/Classes/Camera/PrivacyInfo.xcprivacy']
    }
  end

  # Default — include both
  s.default_subspecs = ['Core', 'Camera']
end
