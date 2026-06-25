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
