package io.arcadiaapps.clocky

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        const val WIDGET_CHANNEL = "clocky/widget"
    }

    private var pendingWidgetAction: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Store widget action for cold-start; dispatch happens in onPostResume
        // after the Flutter engine is fully attached.
        if (intent?.action == ClockWidget.ACTION_WIDGET_BROADCAST) {
            pendingWidgetAction = intent.getStringExtra(ClockWidget.EXTRA_WIDGET_ACTION)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        // App is already running (singleTop), Flutter engine is ready.
        if (intent.action == ClockWidget.ACTION_WIDGET_BROADCAST) {
            dispatchWidgetAction(intent.getStringExtra(ClockWidget.EXTRA_WIDGET_ACTION))
        }
    }

    override fun onPostResume() {
        super.onPostResume()
        // Flutter engine is guaranteed to be attached by this point.
        pendingWidgetAction?.let {
            pendingWidgetAction = null
            dispatchWidgetAction(it)
        }
    }

    private fun dispatchWidgetAction(action: String?) {
        if (action == null) return
        flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
            MethodChannel(messenger, WIDGET_CHANNEL).invokeMethod(action, null)
        }
    }
}
