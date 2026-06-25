package com.erxes.erxes_flutter_sdk

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import androidx.compose.material.icons.Icons
import androidx.compose.ui.graphics.vector.ImageVector

import com.erxes.messenger.ErxesMessenger
import com.erxes.messenger.config.ActionItem
import com.erxes.messenger.config.DisplayMode
import com.erxes.messenger.config.MessengerConfig
import com.erxes.messenger.config.MessengerUser

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Flutter plugin bridging the native [ErxesMessenger] SDK.
 *
 * Android currently supports **chat mode only**; the classic launcher methods
 * (showLauncher/hideLauncher) and hideMessenger resolve as no-ops to keep the
 * shared Dart contract identical to iOS.
 */
class ErxesFlutterSdkPlugin :
    FlutterPlugin,
    ActivityAware,
    MethodCallHandler {

    private lateinit var methodChannel: MethodChannel
    private lateinit var actionChannel: EventChannel
    private lateinit var readyChannel: EventChannel

    private var applicationContext: Context? = null
    private var activity: Activity? = null

    private var actionSink: EventChannel.EventSink? = null
    private var readySink: EventChannel.EventSink? = null

    private val main = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext

        methodChannel = MethodChannel(binding.binaryMessenger, "erxes_flutter_sdk/methods")
        methodChannel.setMethodCallHandler(this)

        actionChannel = EventChannel(binding.binaryMessenger, "erxes_flutter_sdk/events")
        actionChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                actionSink = events
            }

            override fun onCancel(arguments: Any?) {
                actionSink = null
            }
        })

        readyChannel = EventChannel(binding.binaryMessenger, "erxes_flutter_sdk/ready")
        readyChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                readySink = events
            }

            override fun onCancel(arguments: Any?) {
                readySink = null
            }
        })
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        actionChannel.setStreamHandler(null)
        readyChannel.setStreamHandler(null)
        applicationContext = null
    }

    // region ActivityAware

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    // endregion

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "configure" -> configure(call, result)
            "setUser" -> setUser(call, result)
            "clearUser" -> {
                ErxesMessenger.clearUser()
                result.success(null)
            }
            "showMessenger" -> showMessenger(result)
            // Classic launcher is iOS-only; keep the contract identical.
            "showLauncher", "hideLauncher", "hideMessenger" -> result.success(null)
            else -> result.notImplemented()
        }
    }

    private fun configure(call: MethodCall, result: Result) {
        val context = applicationContext
        if (context == null) {
            result.error("no_context", "Plugin is not attached to an engine", null)
            return
        }

        val integrationId = call.argument<String>("integrationId")
        if (integrationId.isNullOrEmpty()) {
            result.error("invalid_args", "integrationId is required", null)
            return
        }

        // endpoint / serverUrl / subDomain are accepted; resolve to an endpoint.
        val endpoint = call.argument<String>("endpoint")
            ?: call.argument<String>("serverUrl")
            ?: call.argument<String>("subDomain")?.let { sub ->
                if (sub.startsWith("http")) sub else "https://$sub"
            }
        if (endpoint.isNullOrEmpty()) {
            result.error("invalid_args", "One of endpoint/serverUrl/subDomain is required", null)
            return
        }

        val cachedCustomerId = call.argument<String>("cachedCustomerId")
        val user = parseUser(call.argument<Map<String, Any?>>("user"))
        val homeActions = parseActions(call.argument<List<Map<String, Any?>>>("homeActions"))
        val drawerActions = parseActions(call.argument<List<Map<String, Any?>>>("drawerActions"))

        val config = MessengerConfig(
            endpoint = endpoint,
            integrationId = integrationId,
            cachedCustomerId = cachedCustomerId,
            // Android implements chat mode only.
            displayMode = DisplayMode.CHAT,
            homeActions = homeActions,
            drawerActions = drawerActions,
        )

        ErxesMessenger.onAction = { id ->
            main.post { actionSink?.success(mapOf("id" to id)) }
        }

        main.post {
            user?.let { ErxesMessenger.setUser(it) }
            ErxesMessenger.configure(context, config)
            // Chat mode presents immediately; mirror RN behaviour.
            activity?.let { ErxesMessenger.show(it) }
            readySink?.success(null)
            result.success(null)
        }
    }

    private fun parseUser(raw: Map<String, Any?>?): MessengerUser? {
        if (raw == null) return null
        return MessengerUser(
            email = raw["email"] as? String,
            name = raw["name"] as? String,
            phone = raw["phone"] as? String,
        )
    }

    private fun setUser(call: MethodCall, result: Result) {
        // customData is intentionally dropped: unsupported by the Android SDK.
        ErxesMessenger.setUser(
            MessengerUser(
                email = call.argument<String>("email"),
                name = call.argument<String>("name"),
                phone = call.argument<String>("phone"),
            )
        )
        result.success(null)
    }

    private fun showMessenger(result: Result) {
        val act = activity
        if (act == null) {
            result.error("no_activity", "No attached activity to present the messenger", null)
            return
        }
        main.post {
            ErxesMessenger.show(act)
            result.success(null)
        }
    }

    private fun parseActions(raw: List<Map<String, Any?>>?): List<ActionItem> {
        if (raw.isNullOrEmpty()) return emptyList()
        return raw.mapNotNull { map ->
            val id = map["id"] as? String ?: return@mapNotNull null
            val title = map["title"] as? String ?: return@mapNotNull null
            val androidIcon = map["androidIcon"] as? String
            ActionItem(
                id = id,
                title = title,
                imageVector = androidIcon?.let { materialIconByName(it) },
                drawableRes = androidIcon?.let { drawableResByName(it) },
            )
        }
    }

    /**
     * Resolves a Material icon by name (e.g. "Close", "Person") using the
     * filled icon set via reflection, matching the RN bridge behaviour.
     */
    private fun materialIconByName(name: String): ImageVector? = try {
        val getter = Icons.Filled::class.java.getMethod("get$name")
        getter.invoke(Icons.Filled) as? ImageVector
    } catch (_: Throwable) {
        null
    }

    /** Resolves a drawable resource by name in the host app's package. */
    private fun drawableResByName(name: String): Int? {
        val context = applicationContext ?: return null
        val resId = context.resources.getIdentifier(name, "drawable", context.packageName)
        return if (resId != 0) resId else null
    }
}
