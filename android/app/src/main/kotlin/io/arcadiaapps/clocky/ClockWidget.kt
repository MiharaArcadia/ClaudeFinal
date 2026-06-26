package io.arcadiaapps.clocky

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.RemoteViews

class ClockWidget : AppWidgetProvider() {

    companion object {
        const val ACTION_WIDGET_BROADCAST = "io.arcadiaapps.clocky.WIDGET_ACTION"
        const val EXTRA_WIDGET_ACTION = "widget_action"
        const val ACTION_START = "start"
        const val ACTION_PAUSE = "pause"
        const val ACTION_STOP = "stop"

        const val PREFS_NAME = "FlutterSharedPreferences"
        const val KEY_TIMER_STATE = "flutter.clocky_timer_state"
        const val KEY_ELAPSED_SECONDS = "flutter.clocky_elapsed_seconds"
        const val KEY_TODAY_HOURS = "flutter.clocky_today_hours"
        const val KEY_PROJECT_NAME = "flutter.clocky_project_name"

        const val STATE_RUNNING = "running"
        const val STATE_PAUSED = "paused"
        const val STATE_STOPPED = "stopped"

        private const val ALARM_REQUEST_CODE = 1001

        /**
         * Updates the 2x2 widget layout for the given appWidgetId.
         * Called by ClockWidget.onUpdate().
         */
        fun updateWidget(context: Context, manager: AppWidgetManager, appWidgetId: Int) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val timerState = prefs.getString(KEY_TIMER_STATE, STATE_STOPPED) ?: STATE_STOPPED
            val elapsedSeconds = prefs.getLong(KEY_ELAPSED_SECONDS, 0L)
            val todayHours = prefs.getString(KEY_TODAY_HOURS, "0h 0m") ?: "0h 0m"
            val projectName = prefs.getString(KEY_PROJECT_NAME, "") ?: ""

            val timeDisplay = formatTime(elapsedSeconds)

            val views = RemoteViews(context.packageName, R.layout.clock_widget)
            views.setTextViewText(R.id.widget_timer, timeDisplay)
            views.setTextViewText(R.id.widget_today, "Heute: $todayHours")
            views.setTextViewText(R.id.widget_project, projectName)

            applyButtonState2x2(views, timerState)

            views.setOnClickPendingIntent(
                R.id.btn_start,
                buildActionPendingIntent(context, ACTION_START, appWidgetId * 10 + 1)
            )
            views.setOnClickPendingIntent(
                R.id.btn_pause,
                buildActionPendingIntent(context, ACTION_PAUSE, appWidgetId * 10 + 2)
            )
            views.setOnClickPendingIntent(
                R.id.btn_stop,
                buildActionPendingIntent(context, ACTION_STOP, appWidgetId * 10 + 3)
            )

            manager.updateAppWidget(appWidgetId, views)
        }

        /**
         * Updates the 4x1 wide widget layout for the given appWidgetId.
         * Called by ClockWidgetWide.onUpdate().
         */
        fun updateWidgetWide(context: Context, manager: AppWidgetManager, appWidgetId: Int) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val timerState = prefs.getString(KEY_TIMER_STATE, STATE_STOPPED) ?: STATE_STOPPED
            val elapsedSeconds = prefs.getLong(KEY_ELAPSED_SECONDS, 0L)
            val todayHours = prefs.getString(KEY_TODAY_HOURS, "0h 0m") ?: "0h 0m"
            val projectName = prefs.getString(KEY_PROJECT_NAME, "") ?: ""

            val timeDisplay = formatTime(elapsedSeconds)

            val views = RemoteViews(context.packageName, R.layout.clock_widget_wide)
            views.setTextViewText(R.id.widget_timer_wide, timeDisplay)
            views.setTextViewText(R.id.widget_today_wide, "Heute: $todayHours")
            views.setTextViewText(R.id.widget_project_wide, projectName)

            applyButtonStateWide(views, timerState)

            views.setOnClickPendingIntent(
                R.id.btn_start_wide,
                buildActionPendingIntent(context, ACTION_START, appWidgetId * 10 + 4)
            )
            views.setOnClickPendingIntent(
                R.id.btn_pause_wide,
                buildActionPendingIntent(context, ACTION_PAUSE, appWidgetId * 10 + 5)
            )
            views.setOnClickPendingIntent(
                R.id.btn_stop_wide,
                buildActionPendingIntent(context, ACTION_STOP, appWidgetId * 10 + 6)
            )

            manager.updateAppWidget(appWidgetId, views)
        }

        private fun applyButtonState2x2(views: RemoteViews, timerState: String) {
            when (timerState) {
                STATE_RUNNING -> {
                    views.setInt(R.id.btn_start, "setBackgroundResource", R.drawable.widget_btn_start)
                    views.setInt(R.id.btn_pause, "setBackgroundResource", R.drawable.widget_btn_outline)
                    views.setInt(R.id.btn_stop, "setBackgroundResource", R.drawable.widget_btn_outline)
                }
                STATE_PAUSED -> {
                    views.setInt(R.id.btn_start, "setBackgroundResource", R.drawable.widget_btn_outline)
                    views.setInt(R.id.btn_pause, "setBackgroundResource", R.drawable.widget_btn_start)
                    views.setInt(R.id.btn_stop, "setBackgroundResource", R.drawable.widget_btn_outline)
                }
                else -> { // STATE_STOPPED or unknown
                    views.setInt(R.id.btn_start, "setBackgroundResource", R.drawable.widget_btn_start)
                    views.setInt(R.id.btn_pause, "setBackgroundResource", R.drawable.widget_btn_outline)
                    views.setInt(R.id.btn_stop, "setBackgroundResource", R.drawable.widget_btn_outline)
                }
            }
        }

        private fun applyButtonStateWide(views: RemoteViews, timerState: String) {
            when (timerState) {
                STATE_RUNNING -> {
                    views.setInt(R.id.btn_start_wide, "setBackgroundResource", R.drawable.widget_btn_start)
                    views.setInt(R.id.btn_pause_wide, "setBackgroundResource", R.drawable.widget_btn_outline)
                    views.setInt(R.id.btn_stop_wide, "setBackgroundResource", R.drawable.widget_btn_outline)
                }
                STATE_PAUSED -> {
                    views.setInt(R.id.btn_start_wide, "setBackgroundResource", R.drawable.widget_btn_outline)
                    views.setInt(R.id.btn_pause_wide, "setBackgroundResource", R.drawable.widget_btn_start)
                    views.setInt(R.id.btn_stop_wide, "setBackgroundResource", R.drawable.widget_btn_outline)
                }
                else -> { // STATE_STOPPED or unknown
                    views.setInt(R.id.btn_start_wide, "setBackgroundResource", R.drawable.widget_btn_start)
                    views.setInt(R.id.btn_pause_wide, "setBackgroundResource", R.drawable.widget_btn_outline)
                    views.setInt(R.id.btn_stop_wide, "setBackgroundResource", R.drawable.widget_btn_outline)
                }
            }
        }

        fun buildActionPendingIntent(context: Context, action: String, requestCode: Int): PendingIntent {
            val intent = Intent(context, MainActivity::class.java).apply {
                this.action = ACTION_WIDGET_BROADCAST
                putExtra(EXTRA_WIDGET_ACTION, action)
                addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            return PendingIntent.getActivity(context, requestCode, intent, flags)
        }

        fun formatTime(totalSeconds: Long): String {
            val h = totalSeconds / 3600
            val m = (totalSeconds % 3600) / 60
            val s = totalSeconds % 60
            return String.format("%02d:%02d:%02d", h, m, s)
        }

        fun scheduleAlarm(context: Context, timerState: String) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(context, ClockWidget::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                val ids = AppWidgetManager.getInstance(context)
                    .getAppWidgetIds(ComponentName(context, ClockWidget::class.java))
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
            }
            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            val pendingIntent = PendingIntent.getBroadcast(context, ALARM_REQUEST_CODE, intent, flags)

            alarmManager.cancel(pendingIntent)

            val intervalMs = if (timerState == STATE_RUNNING) 10_000L else 60_000L
            alarmManager.setRepeating(
                AlarmManager.RTC,
                System.currentTimeMillis() + intervalMs,
                intervalMs,
                pendingIntent
            )
        }

        fun cancelAlarm(context: Context) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(context, ClockWidget::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            }
            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            val pendingIntent = PendingIntent.getBroadcast(context, ALARM_REQUEST_CODE, intent, flags)
            alarmManager.cancel(pendingIntent)
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val timerState = prefs.getString(KEY_TIMER_STATE, STATE_STOPPED) ?: STATE_STOPPED

        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }

        scheduleAlarm(context, timerState)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        // Widget button presses are now delivered as Activity intents to MainActivity.
        // Refresh widget on any relevant system broadcast (e.g. BOOT_COMPLETED).
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val timerState = prefs.getString(KEY_TIMER_STATE, STATE_STOPPED) ?: STATE_STOPPED
        scheduleAlarm(context, timerState)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        cancelAlarm(context)
    }
}
