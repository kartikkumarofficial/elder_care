package com.example.elder_care

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.media.AudioAttributes
import android.os.Build
import android.provider.Settings
import android.util.Log
import androidx.core.app.NotificationCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class MyFirebaseMessagingService : FirebaseMessagingService() {
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        Log.d("FCM_DEBUG", "Message received from: ${remoteMessage.from}")
        
        // Ensure channels are created
        createChannels()

        val data = remoteMessage.data
        if (data.isNotEmpty()) {
            val type = data["type"]
            Log.d("FCM_DEBUG", "Payload type: $type")

            when (type) {
                "schedule_alarm" -> {
                    val alarmId = data["alarm_id"] ?: return
                    val alarmTime = data["alarm_time"]?.toLongOrNull() ?: return
                    val title = data["title"] ?: "Task Reminder"
                    
                    AlarmScheduler.schedule(this, alarmId, alarmTime, title)
                    
                    val advanceTime = alarmTime - (10 * 60 * 1000)
                    if (advanceTime > System.currentTimeMillis()) {
                        AlarmScheduler.scheduleAdvanceNotification(this, alarmId, advanceTime, title)
                    }
                }
                "cancel_alarm" -> {
                    val alarmId = data["alarm_id"] ?: return
                    AlarmScheduler.cancel(this, alarmId)
                }
                "sos" -> {
                    showFullScreenAlarm("SOS", "EMERGENCY ALERT", true)
                }
                "chat" -> {
                    // Handled by Flutter if app is in foreground/background, 
                    // but showing a notification here ensures it appears if the app is killed.
                    showStandardNotification(
                        "chat_channel",
                        data["sender_name"] ?: "New Message",
                        data["message"] ?: "You received a chat message",
                        data["chat_id"]
                    )
                }
                "mood_update", "location_alert", "event_update" -> {
                    showStandardNotification(
                        "update_channel",
                        data["title"] ?: "Update",
                        data["body"] ?: "Update detected",
                        null
                    )
                }
            }
        }

        // If the message contains a notification payload, it is handled by the system 
        // when the app is in the background. If in foreground, we might want to show it.
        // However, Flutter's onMessage will also trigger. To avoid double notifications
        // in foreground, we usually let Flutter handle it.
    }

    private fun showFullScreenAlarm(alarmId: String, title: String, isSOS: Boolean) {
        val intent = Intent(this, AlarmActivity::class.java).apply {
            putExtra("alarm_id", alarmId)
            putExtra("alarm_title", title)
            putExtra("is_sos", isSOS)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }

        val pendingIntent = PendingIntent.getActivity(
            this,
            alarmId.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder = NotificationCompat.Builder(this, ALARM_CHANNEL)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(if (isSOS) "EMERGENCY - Tap to Respond" else "Time for your task")
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setFullScreenIntent(pendingIntent, true)
            .setOngoing(true)
            .setAutoCancel(false)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)

        val manager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(alarmId.hashCode(), builder.build())
    }

    private fun showStandardNotification(channelId: String, title: String, body: String, extraId: String?) {
        val intent = Intent(this, MainActivity::class.java).apply {
            putExtra("extra_id", extraId)
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }

        val pendingIntent = PendingIntent.getActivity(
            this,
            (title + body).hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(pendingIntent)

        val manager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        manager.notify((title + body).hashCode(), builder.build())
    }

    private fun createChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(NotificationManager::class.java)

            // Alarms: High Importance + Alarm Sound
            val alarmChannel = NotificationChannel(ALARM_CHANNEL, "Alarms", NotificationManager.IMPORTANCE_HIGH).apply {
                enableVibration(true)
                setSound(Settings.System.DEFAULT_ALARM_ALERT_URI, AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .build())
            }

            // Chat: High Importance for Heads-up
            val chatChannel = NotificationChannel("chat_channel", "Chat Messages", NotificationManager.IMPORTANCE_HIGH)
            
            // Updates: High Importance for Heads-up
            val updateChannel = NotificationChannel("update_channel", "Receiver Updates", NotificationManager.IMPORTANCE_HIGH)
            
            // Default: High Importance for Heads-up
            val defaultChannel = NotificationChannel("default_channel", "General Notifications", NotificationManager.IMPORTANCE_HIGH)

            manager.createNotificationChannels(listOf(alarmChannel, chatChannel, updateChannel, defaultChannel))
        }
    }

    override fun onNewToken(token: String) {
        Log.d("FCM_DEBUG", "New token: $token")
    }

    companion object {
        const val ALARM_CHANNEL = "alarm_channel"
    }
}
