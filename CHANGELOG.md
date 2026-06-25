## 0.2.0

* Pass `user` during configure so native SDKs identify the visitor before connecting.
* Apply user before native messenger configuration on iOS and Android.
* Remove `primaryColor` from the Flutter API and native bridge.

## 0.1.2

* Fix iOS build against MessengerSDK 0.30.13: hop all `@MainActor`-isolated
  SDK calls to the main thread, use the nested `MessengerConfig.Appearance`
  value type, and match the non-optional `MessengerUser.customData` and
  `ActionItem.systemIcon` signatures.
* Bump the example app's iOS deployment target to 16.0 to satisfy the SDK.

## 0.1.1

* Remove unused import in example widget test.
* Scope README to chat mode and drop maintainer-only release notes.

## 0.1.0

* Initial release.
* `ErxesMessenger` API: `configure`, `setUser`, `clearUser`, `showMessenger`,
  `hideMessenger`, `showLauncher`, `hideLauncher`, plus `onAction` and `onReady`
  streams.
* Android: wraps `io.github.munkhorgilb:messenger-sdk` (chat mode).
* iOS: wraps `MessengerSDK` from `erxes-ios-sdk` via Swift Package Manager
  (chat + classic launcher).
