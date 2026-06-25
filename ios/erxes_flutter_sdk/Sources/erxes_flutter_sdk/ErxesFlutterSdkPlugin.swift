import Flutter
import UIKit
import MessengerSDK

/// Flutter plugin bridging the native `MessengerSDK`.
///
/// Commands arrive on the `erxes_flutter_sdk/methods` method channel; tapped
/// action ids are streamed back over the `erxes_flutter_sdk/events` event
/// channel.
public class ErxesFlutterSdkPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

  private var actionSink: FlutterEventSink?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let messenger = registrar.messenger()

    let methodChannel = FlutterMethodChannel(
      name: "erxes_flutter_sdk/methods", binaryMessenger: messenger)
    let instance = ErxesFlutterSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: methodChannel)

    let actionChannel = FlutterEventChannel(
      name: "erxes_flutter_sdk/events", binaryMessenger: messenger)
    actionChannel.setStreamHandler(instance)
  }

  // MARK: - FlutterStreamHandler

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    actionSink = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    actionSink = nil
    return nil
  }

  // MARK: - Method handling

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "configure":
      configure(call.arguments as? [String: Any] ?? [:], result: result)
    case "setUser":
      setUser(call.arguments as? [String: Any] ?? [:], result: result)
    case "clearUser":
      DispatchQueue.main.async { MessengerSDK.clearUser() }
      result(nil)
    case "showMessenger":
      DispatchQueue.main.async {
        if let top = Self.topViewController() {
          MessengerSDK.showMessenger(from: top)
        }
      }
      result(nil)
    case "hideMessenger":
      DispatchQueue.main.async { MessengerSDK.hideMessenger() }
      result(nil)
    case "showLauncher":
      DispatchQueue.main.async { MessengerSDK.showLauncher() }
      result(nil)
    case "hideLauncher":
      DispatchQueue.main.async { MessengerSDK.hideLauncher() }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func configure(_ options: [String: Any], result: @escaping FlutterResult) {
    guard let integrationId = options["integrationId"] as? String, !integrationId.isEmpty else {
      result(FlutterError(code: "invalid_args", message: "integrationId is required", details: nil))
      return
    }

    let endpoint =
      (options["endpoint"] as? String)
      ?? (options["serverUrl"] as? String)
      ?? (options["subDomain"] as? String).map { $0.hasPrefix("http") ? $0 : "https://\($0)" }

    guard let endpoint, !endpoint.isEmpty else {
      result(
        FlutterError(
          code: "invalid_args",
          message: "One of endpoint/serverUrl/subDomain is required", details: nil))
      return
    }

    let displayMode =
      (options["displayMode"] as? String).flatMap(DisplayMode.init(rawValue:)) ?? .classic

    let cachedCustomerId = options["cachedCustomerId"] as? String
    let user = Self.parseUser(options["user"])
    let homeActions = Self.parseActions(options["homeActions"])
    let drawerActions = Self.parseActions(options["drawerActions"])

    DispatchQueue.main.async { [weak self] in
      if let user {
        MessengerSDK.setUser(user)
      }
      MessengerSDK.configure(
        MessengerConfig(
          endpoint: endpoint,
          integrationId: integrationId,
          cachedCustomerId: cachedCustomerId,
          displayMode: displayMode,
          homeActions: homeActions,
          drawerActions: drawerActions
        )
      )
      MessengerSDK.shared.onAction = { [weak self] id in
        self?.actionSink?(["id": id])
      }
    }

    result(nil)
  }

  private func setUser(_ options: [String: Any], result: @escaping FlutterResult) {
    let user = MessengerUser(
      email: options["email"] as? String,
      phone: options["phone"] as? String,
      name: options["name"] as? String,
      customData: options["customData"] as? [String: String] ?? [:]
    )
    DispatchQueue.main.async { MessengerSDK.setUser(user) }
    result(nil)
  }

  // MARK: - Helpers

  private static func parseActions(_ raw: Any?) -> [ActionItem] {
    guard let list = raw as? [[String: Any]] else { return [] }
    return list.compactMap { map in
      guard let id = map["id"] as? String, let title = map["title"] as? String else { return nil }
      // The Dart layer mirrors iosIcon into `systemIcon`.
      // ActionItem requires a non-optional icon; skip entries with neither.
      guard let systemIcon = (map["systemIcon"] as? String) ?? (map["iosIcon"] as? String)
      else { return nil }
      return ActionItem(id: id, title: title, systemIcon: systemIcon)
    }
  }

  private static func parseUser(_ raw: Any?) -> MessengerUser? {
    guard let map = raw as? [String: Any] else { return nil }
    return MessengerUser(
      email: map["email"] as? String,
      phone: map["phone"] as? String,
      name: map["name"] as? String,
      customData: map["customData"] as? [String: String] ?? [:]
    )
  }

  /// Returns the deepest visible view controller to present the messenger from.
  private static func topViewController(from root: UIViewController? = nil) -> UIViewController? {
    let base = root ?? keyWindow()?.rootViewController
    if let nav = base as? UINavigationController {
      return topViewController(from: nav.visibleViewController)
    }
    if let tab = base as? UITabBarController {
      return topViewController(from: tab.selectedViewController)
    }
    if let presented = base?.presentedViewController {
      return topViewController(from: presented)
    }
    return base
  }

  private static func keyWindow() -> UIWindow? {
    return UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
  }
}
