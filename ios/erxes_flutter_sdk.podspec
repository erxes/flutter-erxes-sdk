#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint erxes_flutter_sdk.podspec` to validate before publishing.
#
# The underlying `erxes-ios-sdk` is published to CocoaPods as `ErxesMessengerSDK`
# (module `MessengerSDK`) starting with 0.30.14, so the host app no longer needs
# Flutter's Swift Package Manager support enabled. The SPM manifest in
# ios/erxes_flutter_sdk/Package.swift is kept for SPM-based host apps.
#
Pod::Spec.new do |s|
  s.name             = 'erxes_flutter_sdk'
  s.version          = '0.3.0'
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
  s.dependency 'ErxesMessengerSDK', '0.30.14'
  s.platform = :ios, '16.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.9'
end
