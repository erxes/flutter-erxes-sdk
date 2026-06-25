## 0.1.0

* Initial release.
* `ErxesMessenger` API: `configure`, `setUser`, `clearUser`, `showMessenger`,
  `hideMessenger`, `showLauncher`, `hideLauncher`, plus `onAction` and `onReady`
  streams.
* Android: wraps `io.github.munkhorgilb:messenger-sdk` (chat mode).
* iOS: wraps `MessengerSDK` from `erxes-ios-sdk` via Swift Package Manager
  (chat + classic launcher).
