/// Display mode for the Erxes messenger.
///
/// - [classic] shows a draggable floating launcher button (iOS only).
/// - [chat] presents a full-screen chat interface with header/drawer actions
///   and voice-message support.
///
/// Android currently implements **chat mode only**; the classic floating
/// launcher is iOS-only for now.
enum ErxesDisplayMode { classic, chat }

/// Identity information for the current visitor/customer.
///
/// All fields are optional. Alternatively, pass `cachedCustomerId` to
/// [ErxesMessenger.configure] to reuse a previously created customer identity.
class ErxesUser {
  const ErxesUser({this.email, this.phone, this.name, this.customData});

  final String? email;
  final String? phone;
  final String? name;

  /// Arbitrary key/value metadata attached to the customer.
  ///
  /// Note: `customData` is currently supported on iOS only; the Android native
  /// SDK ignores it.
  final Map<String, String>? customData;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'email': email,
    'phone': phone,
    'name': name,
    'customData': customData,
  }..removeWhere((_, value) => value == null);
}

/// A custom action rendered in the messenger header (`homeActions`) or the
/// drawer (`drawerActions`).
///
/// When the user taps an action, its [id] is delivered through
/// [ErxesMessenger.onAction].
class ErxesAction {
  const ErxesAction({
    required this.id,
    required this.title,
    this.iosIcon,
    this.androidIcon,
  });

  /// Stable identifier delivered via [ErxesMessenger.onAction] when tapped.
  final String id;

  /// Visible label for the action.
  final String title;

  /// SF Symbol name used on iOS (e.g. `xmark`, `person`).
  final String? iosIcon;

  /// Material icon name or drawable resource name used on Android
  /// (e.g. `Close`, `Person`).
  final String? androidIcon;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'title': title,
    'iosIcon': iosIcon,
    'androidIcon': androidIcon,
    // The native iOS bridge reads `systemIcon`; keep the alias so both
    // platforms can consume the same payload.
    'systemIcon': iosIcon,
  }..removeWhere((_, value) => value == null);
}
