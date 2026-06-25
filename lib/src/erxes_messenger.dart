import 'dart:async';

import 'package:flutter/services.dart';

import 'models.dart';

/// Entry point for the Erxes messenger.
///
/// This is a thin, idiomatic wrapper over the native Erxes messenger SDKs
/// (`MessengerSDK` on iOS, `ErxesMessenger` on Android), bridged through a
/// [MethodChannel] for commands and an [EventChannel] for action events.
///
/// Typical usage:
///
/// ```dart
/// final sub = ErxesMessenger.onAction.listen((id) {
///   if (id == 'close') Navigator.of(context).pop();
/// });
///
/// await ErxesMessenger.configure(
///   integrationId: 'YOUR_INTEGRATION_ID',
///   endpoint: 'https://yourcompany.erxes.io',
///   displayMode: ErxesDisplayMode.chat,
///   primaryColor: '#7c3aed',
///   user: const ErxesUser(name: 'Jane Doe', email: 'user@example.com'),
///   homeActions: const [
///     ErxesAction(id: 'close', title: 'Close', iosIcon: 'xmark', androidIcon: 'Close'),
///   ],
/// );
/// ```
class ErxesMessenger {
  ErxesMessenger._();

  static const MethodChannel _methods = MethodChannel(
    'erxes_flutter_sdk/methods',
  );
  static const EventChannel _actionEvents = EventChannel(
    'erxes_flutter_sdk/events',
  );
  static const EventChannel _readyEvents = EventChannel(
    'erxes_flutter_sdk/ready',
  );

  static Stream<String>? _onAction;
  static Stream<void>? _onReady;

  /// Emits the [ErxesAction.id] of each tapped header/drawer action.
  static Stream<String> get onAction {
    _onAction ??= _actionEvents.receiveBroadcastStream().map((dynamic event) {
      final map = Map<dynamic, dynamic>.from(event as Map);
      return map['id'] as String;
    });
    return _onAction!;
  }

  /// Emits once the messenger reports it is ready/loaded.
  static Stream<void> get onReady {
    _onReady ??= _readyEvents.receiveBroadcastStream().map((_) {});
    return _onReady!;
  }

  /// Configures the messenger and, in [ErxesDisplayMode.chat], presents it.
  ///
  /// Provide exactly one of [endpoint], [serverUrl] or [subDomain]
  /// (e.g. `'company.erxes.io'`). If [user] is supplied it is forwarded via
  /// [setUser] after configuration.
  ///
  /// On Android only [ErxesDisplayMode.chat] is supported; [displayMode] is
  /// effectively ignored there.
  static Future<void> configure({
    required String integrationId,
    String? endpoint,
    String? serverUrl,
    String? subDomain,
    String? cachedCustomerId,
    ErxesDisplayMode displayMode = ErxesDisplayMode.chat,
    String? primaryColor,
    ErxesUser? user,
    List<ErxesAction> homeActions = const <ErxesAction>[],
    List<ErxesAction> drawerActions = const <ErxesAction>[],
  }) async {
    final args = <String, dynamic>{
      'integrationId': integrationId,
      'endpoint': endpoint,
      'serverUrl': serverUrl,
      'subDomain': subDomain,
      'cachedCustomerId': cachedCustomerId,
      'displayMode': displayMode.name,
      'primaryColor': primaryColor,
      'homeActions': homeActions.map((a) => a.toMap()).toList(),
      'drawerActions': drawerActions.map((a) => a.toMap()).toList(),
    }..removeWhere((_, value) => value == null);

    await _methods.invokeMethod<void>('configure', args);

    if (user != null) {
      await setUser(user);
    }
  }

  /// Updates the identity of the current customer.
  static Future<void> setUser(ErxesUser user) {
    return _methods.invokeMethod<void>('setUser', user.toMap());
  }

  /// Clears the current customer identity.
  static Future<void> clearUser() {
    return _methods.invokeMethod<void>('clearUser');
  }

  /// Presents the messenger UI.
  static Future<void> showMessenger() {
    return _methods.invokeMethod<void>('showMessenger');
  }

  /// Dismisses the messenger UI.
  ///
  /// No-op on Android (the messenger is a standard screen there).
  static Future<void> hideMessenger() {
    return _methods.invokeMethod<void>('hideMessenger');
  }

  /// Shows the classic floating launcher button.
  ///
  /// iOS-only; resolves as a no-op on Android.
  static Future<void> showLauncher() {
    return _methods.invokeMethod<void>('showLauncher');
  }

  /// Hides the classic floating launcher button.
  ///
  /// iOS-only; resolves as a no-op on Android.
  static Future<void> hideLauncher() {
    return _methods.invokeMethod<void>('hideLauncher');
  }
}
