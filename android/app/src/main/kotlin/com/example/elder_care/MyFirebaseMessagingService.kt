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
        Log.d("FCM_DEBUG", "Message received!")
        Log.d("FCM_DEBUG", "Data: " + remoteMessage.getData())
        Log.d("FCM_DEBUG", "Notification: " + remoteMessage.getNotification())

        createChannels()

        // Handle DATA payload
        if (remoteMessage.getData().size > 0) {
            val type = remoteMessage.getData().get("type")
            val alarmId = remoteMessage.getData().get("alarm_id")

            Log.d("FCM_DEBUG", "Type: " + type)
            Log.d("FCM_DEBUG", "AlarmId: " + alarmId)

            if ("alarm" == type) {
                showFullScreenAlarm(alarmId!!)
            }

            if ("alarm_missed" == type) {
                showMissedNotification(alarmId)
            }
        }

        // Handle NOTIFICATION payload (important when app is killed)
        if (remoteMessage.getNotification() != null) {
            Log.d(
                "FCM_DEBUG", "Notification title: "
                        + remoteMessage.getNotification()!!.getTitle()
            )
        }
    }


    private fun showFullScreenAlarm(alarmId: String) {
        val intent = Intent(this, AlarmActivity::class.java)
        intent.putExtra("alarm_id", alarmId)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)

        val fullScreenIntent = PendingIntent.getActivity(
            this,
            alarmId.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder: NotificationCompat.Builder =
            NotificationCompat.Builder(this, ALARM_CHANNEL)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle("Medicine Reminder")
                .setContentText("Tap to respond")
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setFullScreenIntent(fullScreenIntent, true)
                .setOngoing(true)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setAutoCancel(false)

        val manager =
            getSystemService(NOTIFICATION_SERVICE) as NotificationManager

        manager.notify(alarmId.hashCode(), builder.build())
    }

    private fun showMissedNotification(alarmId: String?) {
        val intent = Intent(this, MainActivity::class.java)
        intent.putExtra("alarm_id", alarmId)

        val pendingIntent = PendingIntent.getActivity(
            this,
            1,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder: NotificationCompat.Builder =
            NotificationCompat.Builder(this, MISSED_CHANNEL)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle("Missed Alarm")
                .setContentText("Receiver did not respond")
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setAutoCancel(true)
                .setContentIntent(pendingIntent)

        val manager =
            getSystemService(NOTIFICATION_SERVICE) as NotificationManager

        manager.notify(1001, builder.build())
    }

    private fun createChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager =
                getSystemService<NotificationManager>(NotificationManager::class.java)

            val alarmChannel =
                NotificationChannel(
                    ALARM_CHANNEL,
                    "Alarms",
                    NotificationManager.IMPORTANCE_HIGH
                )

            alarmChannel.enableVibration(true)
            alarmChannel.setLockscreenVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            alarmChannel.setSound(
                Settings.System.DEFAULT_ALARM_ALERT_URI,
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .build()
            )

            val missedChannel =
                NotificationChannel(
                    MISSED_CHANNEL,
                    "Missed Alarms",
                    NotificationManager.IMPORTANCE_HIGH
                )

            manager.createNotificationChannel(alarmChannel)
            manager.createNotificationChannel(missedChannel)
        }
    }

    companion object {
        private const val ALARM_CHANNEL = "alarm_channel"
        private const val MISSED_CHANNEL = "missed_channel"
    }
}
