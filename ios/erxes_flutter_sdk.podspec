#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint erxes_flutter_sdk.podspec` to validate before publishing.
#
# NOTE: The underlying `erxes-ios-sdk` (`MessengerSDK`) is distributed via Swift
# Package Manager only. This plugin therefore requires Flutter's Swift Package
# Manager support to be enabled in the host app:
#
#     flutter config --enable-swift-package-manager
#
# See ios/erxes_flutter_sdk/Package.swift for the SPM dependency declaration.
#
Pod::Spec.new do |s|
  s.name             = 'erxes_flutter_sdk'
  s.version          = '0.1.0'
  s.summary          = 'Flutter plugin for the Erxes messenger.'
  s.description      = <<-DESC
Flutter plugin wrapping the native Erxes MessengerSDK for iOS.
                       DESC
  s.homepage         = 'https://github.com/Munkhorgilb/flutter-sdk'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Erxes' => 'info@erxes.io' }
  s.source           = { :path => '.' }
  # Shared with the Swift Package Manager target (single source of truth).
  s.source_files = 'erxes_flutter_sdk/Sources/erxes_flutter_sdk/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '16.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.9'
end
