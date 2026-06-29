package com.example.elder_care

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val type = intent.getStringExtra("type") ?: "ALARM_TRIGGER"
        val alarmId = intent.getStringExtra("alarm_id") ?: "default"
        val title = intent.getStringExtra("alarm_title") ?: "Task Reminder"
        val dosage = intent.getStringExtra("dosage")
        val instructions = intent.getStringExtra("instructions")

        Log.d("AlarmReceiver", "🔔 Received broadcast: $type for $alarmId")

        when (type) {
            "ALARM_TRIGGER" -> {
                startAlarmService(context, alarmId, title, dosage, instructions, false)
            }
            "SOS_TRIGGER" -> {
                startAlarmService(context, "SOS", "EMERGENCY ALERT", null, null, true)
            }
            "ADVANCE_NOTIFICATION" -> {
                // Keep existing advance notification logic or move to service if preferred
                // For now, keeping it simple as it's just a reminder notification
                showAdvanceNotification(context, alarmId, title)
            }
        }
    }

    private fun startAlarmService(
        context: Context,
        alarmId: String,
        title: String,
        dosage: String?,
        instructions: String?,
        isSOS: Boolean
    ) {
        val serviceIntent = Intent(context, AlarmService::class.java).apply {
            putExtra("alarm_id", alarmId)
            putExtra("alarm_title", title)
            putExtra("dosage", dosage)
            putExtra("instructions", instructions)
            putExtra("is_sos", isSOS)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(serviceIntent)
        } else {
            context.startService(serviceIntent)
        }
    }

    private fun showAdvanceNotification(context: Context, alarmId: String, title: String) {
        // Implementation remains similar but uses the common channel
        val intent = Intent(context, MainActivity::class.java).apply {
            putExtra("alarm_id", alarmId)
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }

        val pendingIntent = android.app.PendingIntent.getActivity(
            context,
            alarmId.hashCode() + 2,
            intent,
            android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
        )

        val builder = androidx.core.app.NotificationCompat.Builder(context, "update_channel")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Upcoming: $title")
            .setContentText("Tap to view details.")
            .setPriority(androidx.core.app.NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
        manager.notify(alarmId.hashCode() + 2, builder.build())
    }

    companion object {
        const val ALARM_CHANNEL = "alarm_channel"
    }
}
