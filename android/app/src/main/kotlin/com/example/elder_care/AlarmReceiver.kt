package com.example.elder_care

import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.core.app.NotificationCompat

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val type = intent.getStringExtra("type")
        val alarmId = intent.getStringExtra("alarm_id") ?: "default"
        val title = intent.getStringExtra("alarm_title") ?: "Reminder"

        Log.d("AlarmReceiver", "Received broadcast: $type for $alarmId")

        when (type) {
            "ALARM_TRIGGER" -> {
                val i = Intent(context, AlarmActivity::class.java).apply {
                    putExtra("alarm_id", alarmId)
                    putExtra("alarm_title", title)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                }
                context.startActivity(i)
            }
            "ADVANCE_NOTIFICATION" -> {
                showAdvanceNotification(context, alarmId, title)
            }
            "SOS_TRIGGER" -> {
                val i = Intent(context, AlarmActivity::class.java).apply {
                    putExtra("alarm_id", "SOS")
                    putExtra("alarm_title", "EMERGENCY")
                    putExtra("is_sos", true)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                }
                context.startActivity(i)
            }
        }
    }

    private fun showAdvanceNotification(context: Context, alarmId: String, title: String) {
        val intent = Intent(context, MainActivity::class.java).apply {
            putExtra("alarm_id", alarmId)
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }

        val pendingIntent = PendingIntent.getActivity(
            context,
            alarmId.hashCode() + 2,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder = NotificationCompat.Builder(context, "alarm_channel")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Upcoming: $title")
            .setContentText("Tap to view details and mark as completed.")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(alarmId.hashCode() + 2, builder.build())
    }
}
