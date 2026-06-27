package com.example.elder_care

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log

object AlarmScheduler {
    private const val TAG = "AlarmScheduler"

    @JvmStatic
    fun schedule(context: Context, alarmId: String, triggerTime: Long, title: String) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (!alarmManager.canScheduleExactAlarms()) {
                Log.w(TAG, "Cannot schedule exact alarms. Requesting permission.")
                val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                    data = Uri.parse("package:${context.packageName}")
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                context.startActivity(intent)
                return
            }
        }

        val intent = Intent(context, AlarmReceiver::class.java).apply {
            putExtra("alarm_id", alarmId)
            putExtra("alarm_title", title)
            putExtra("type", "ALARM_TRIGGER")
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            alarmId.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        try {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                triggerTime,
                pendingIntent
            )
            Log.d(TAG, "Alarm scheduled for $alarmId at $triggerTime")
        } catch (e: SecurityException) {
            Log.e(TAG, "SecurityException scheduling alarm", e)
        }
    }

    @JvmStatic
    fun scheduleAdvanceNotification(context: Context, alarmId: String, triggerTime: Long, title: String) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val intent = Intent(context, AlarmReceiver::class.java).apply {
            putExtra("alarm_id", alarmId)
            putExtra("alarm_title", title)
            putExtra("type", "ADVANCE_NOTIFICATION")
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            alarmId.hashCode() + 1, // Unique ID for advance notification
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        alarmManager.setAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            triggerTime,
            pendingIntent
        )
        Log.d(TAG, "Advance notification scheduled for $alarmId at $triggerTime")
    }

    @JvmStatic
    fun cancel(context: Context, alarmId: String) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        
        val intent = Intent(context, AlarmReceiver::class.java)
        
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            alarmId.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val advancePendingIntent = PendingIntent.getBroadcast(
            context,
            alarmId.hashCode() + 1,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        alarmManager.cancel(pendingIntent)
        alarmManager.cancel(advancePendingIntent)
        Log.d(TAG, "Alarm and advance notification canceled for $alarmId")
    }
}
