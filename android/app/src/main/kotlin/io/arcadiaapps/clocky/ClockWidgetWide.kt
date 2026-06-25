package io.arcadiaapps.clocky

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent

/**
 * 4x1 wide variant of the Clocky home screen widget.
 * Delegates all SharedPreferences reading and view inflation to
 * ClockWidget companion helpers so both sizes always reflect the same state.
 */
class ClockWidgetWide : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            ClockWidget.updateWidgetWide(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ClockWidget.ACTION_WIDGET_BROADCAST) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, ClockWidgetWide::class.java)
            )
            onUpdate(context, manager, ids)
        }
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
    }
}
