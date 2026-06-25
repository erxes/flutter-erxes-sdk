# erxes_flutter_sdk

Flutter plugin for the [Erxes](https://erxes.io) messenger. It wraps the native
Erxes SDKs — `MessengerSDK` (iOS) and `io.github.munkhorgilb:messenger-sdk`
(Android) — behind one idiomatic Dart API built on platform channels.

> **Repository:** `erxes-flutter-sdk` · **Package name:** `erxes_flutter_sdk`
> (pub package names use `snake_case`).

## Platform support

| Feature | iOS | Android |
| --- | :---: | :---: |
| Chat mode (full screen) | ✅ | ✅ |
| Voice messages | ✅ | ✅ |
| `customData` on user | ✅ | ❌ (ignored by native SDK) |

This plugin targets **chat mode** only.

## Install

```yaml
dependencies:
  erxes_flutter_sdk:
    git:
      url: https://github.com/Munkhorgilb/flutter-sdk.git
```

### iOS setup

- Minimum iOS **16.0**, Swift **5.9**.
- The underlying `erxes-ios-sdk` is distributed via **Swift Package Manager only**,
  so enable Flutter's SPM support in the host app:

  ```bash
  flutter config --enable-swift-package-manager
  ```

- For voice messages, add to `ios/Runner/Info.plist`:

  ```xml
  <key>NSMicrophoneUsageDescription</key>
  <string>Used to record voice messages in support chat.</string>
  <key>NSSpeechRecognitionUsageDescription</key>
  <string>Used to transcribe voice messages in support chat.</string>
  ```

### Android setup

- Minimum `minSdk` **24**, Java/Kotlin JVM target **17**.
- The native SDK (`io.github.munkhorgilb:messenger-sdk`) is pulled from Maven
  Central automatically.
- Release builds: the plugin ships consumer ProGuard rules that keep Material
  icon and Erxes SDK classes used to resolve action icons by name.

## Usage

```dart
import 'package:erxes_flutter_sdk/erxes_flutter_sdk.dart';

// Listen for header / drawer action taps.
final sub = ErxesMessenger.onAction.listen((id) {
  if (id == 'close') Navigator.of(context).pop();
});

await ErxesMessenger.configure(
  integrationId: 'YOUR_INTEGRATION_ID',
  endpoint: 'https://yourcompany.erxes.io', // or serverUrl / subDomain
  user: const ErxesUser(name: 'Jane Doe', email: 'user@example.com'),
  homeActions: const [
    ErxesAction(id: 'close', title: 'Close', iosIcon: 'xmark', androidIcon: 'Close'),
  ],
);
```

See [`example/`](example/) for a full settings → support → chat flow.

## API

| Method | Description |
| --- | --- |
| `configure({...})` | Configure and (in chat mode) present the messenger. |
| `setUser(ErxesUser)` | Update the current customer identity. |
| `clearUser()` | Clear the current customer identity. |
| `showMessenger()` | Present the chat messenger UI. |
| `hideMessenger()` | Dismiss the messenger (no-op on Android). |
| `onAction` | `Stream<String>` of tapped action ids. |
| `onReady` | `Stream<void>` emitted when the messenger is ready. |

### Models

- `ErxesUser({ email, phone, name, customData })`
- `ErxesAction({ id, title, iosIcon, androidIcon })`

## Troubleshooting

- **iOS build can't find `MessengerSDK`** — enable Swift Package Manager:
  `flutter config --enable-swift-package-manager`, then `flutter clean` and rebuild.
- **Android action icons missing in release** — confirm minification didn't strip
  icon classes; the bundled `consumer-rules.pro` should cover this.
