package com.example.elder_care

import android.app.*
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.*
import android.provider.Settings
import android.util.Log
import androidx.core.app.NotificationCompat

/**
 * Foreground service to handle the alarm ringing and vibration.
 * Ensures the alarm continues even if the Activity is destroyed or backgrounded.
 */
class AlarmService : Service() {
    private var mediaPlayer: MediaPlayer? = null
    private var vibrator: Vibrator? = null
    private var wakeLock: PowerManager.WakeLock? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val alarmId = intent?.getStringExtra("alarm_id") ?: "unknown"
        val title = intent?.getStringExtra("alarm_title") ?: "Task Reminder"
        val dosage = intent?.getStringExtra("dosage")
        val instructions = intent?.getStringExtra("instructions")
        val isSOS = intent?.getBooleanExtra("is_sos", false) ?: false
        val action = intent?.action

        if (action == ACTION_STOP_ALARM) {
            Log.d("AlarmService", "Stopping alarm service for $alarmId")
            stopForeground(true)
            stopSelf()
            return START_NOT_STICKY
        }

        Log.d("AlarmService", "🔔 Starting alarm service for $alarmId")

        acquireWakeLock()
        showNotification(alarmId, title, dosage, instructions, isSOS)
        startAlarm(isSOS)

        return START_STICKY
    }

    private fun acquireWakeLock() {
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP,
            "ElderCare:AlarmWakeLock"
        )
        wakeLock?.acquire(10 * 60 * 1000L /* 10 minutes */)
    }

    private fun showNotification(
        alarmId: String,
        title: String,
        dosage: String?,
        instructions: String?,
        isSOS: Boolean
    ) {
        val fullScreenIntent = Intent(this, AlarmActivity::class.java).apply {
            putExtra("alarm_id", alarmId)
            putExtra("alarm_title", title)
            putExtra("dosage", dosage)
            putExtra("instructions", instructions)
            putExtra("is_sos", isSOS)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_NO_USER_ACTION)
        }

        val fullScreenPendingIntent = PendingIntent.getActivity(
            this,
            alarmId.hashCode(),
            fullScreenIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val stopIntent = Intent(this, AlarmService::class.java).apply {
            action = ACTION_STOP_ALARM
        }
        val stopPendingIntent = PendingIntent.getService(
            this,
            alarmId.hashCode(),
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val channelId = AlarmReceiver.ALARM_CHANNEL
        
        // Ensure channel exists
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = manager.getNotificationChannel(channelId)
            if (channel == null) {
                val newChannel = NotificationChannel(
                    channelId,
                    "Alarms",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    enableVibration(true)
                    setSound(null, null) // Sound is handled by MediaPlayer in Service
                    lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                }
                manager.createNotificationChannel(newChannel)
            }
        }

        val notification = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(if (isSOS) "EMERGENCY ALERT - Action Required" else "Time for your task: $title")
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setFullScreenIntent(fullScreenPendingIntent, true)
            .setOngoing(true)
            .setAutoCancel(false)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .addAction(android.R.drawable.ic_menu_close_clear_cancel, "DISMISS", stopPendingIntent)
            .build()

        startForeground(alarmId.hashCode().let { if (it == 0) 1 else it }, notification)
    }

    private fun startAlarm(isSOS: Boolean) {
        try {
            val alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)

            mediaPlayer = MediaPlayer().apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build()
                )
                setDataSource(this@AlarmService, alarmUri)
                isLooping = true
                prepare()
                start()
            }

            vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
                vibratorManager.defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            }

            val pattern = if (isSOS) longArrayOf(0, 1000, 200) else longArrayOf(0, 500, 500)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator?.vibrate(VibrationEffect.createWaveform(pattern, 0))
            } else {
                @Suppress("DEPRECATION")
                vibrator?.vibrate(pattern, 0)
            }
        } catch (e: Exception) {
            Log.e("AlarmService", "Error starting alarm sounds/vibration", e)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        mediaPlayer?.stop()
        mediaPlayer?.release()
        mediaPlayer = null
        vibrator?.cancel()
        wakeLock?.let {
            if (it.isHeld) it.release()
        }
        Log.d("AlarmService", "Alarm service stopped and resources released")
    }

    override fun onBind(intent: Intent?): IBinder? = null

    companion object {
        const val ACTION_STOP_ALARM = "com.example.elder_care.STOP_ALARM"
    }
}
