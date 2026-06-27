package com.example.elder_care

import android.app.Activity
import android.app.KeyguardManager
import android.content.Context
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Build
import android.os.Bundle
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.util.Log
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class AlarmActivity : Activity() {
    private var mediaPlayer: MediaPlayer? = null
    private var vibrator: Vibrator? = null
    private var tvTime: TextView? = null
    private var tvDate: TextView? = null
    private var tvTitle: TextView? = null
    private var btnStop: Button? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("ALARM_DEBUG", "AlarmActivity launched")

        // 🔥 Professional Unlock & Wake Screen logic for Alarms
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
            val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
            keyguardManager.requestDismissKeyguard(this, null)
        } else {
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                        WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                        WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }

        setContentView(R.layout.activity_alarm)

        tvTime = findViewById(R.id.tvTime)
        tvDate = findViewById(R.id.tvDate)
        tvTitle = findViewById(R.id.tvTitle)
        btnStop = findViewById(R.id.btnStop)

        // Set Current Time & Date
        val now = Date()
        val timeFormat = SimpleDateFormat("HH:mm", Locale.getDefault())
        val dateFormat = SimpleDateFormat("EEEE, MMM dd", Locale.getDefault())

        tvTime?.text = timeFormat.format(now)
        tvDate?.text = dateFormat.format(now)

        // Handle Alarm or SOS specific styling
        val alarmTitle = intent.getStringExtra("alarm_title")
        val isSOS = intent.getBooleanExtra("is_sos", false)

        if (isSOS) {
            tvTitle?.text = "EMERGENCY ALERT (SOS)"
            tvTitle?.setTextColor(0xFFFF0000.toInt()) // High-visibility red
        } else if (!alarmTitle.isNullOrEmpty()) {
            tvTitle?.text = alarmTitle
        } else {
            tvTitle?.text = "Task Reminder"
        }

        startAlarmSound(isSOS)
        startVibration(isSOS)

        btnStop?.setOnClickListener { stopAlarm() }
    }

    private fun startAlarmSound(isSOS: Boolean) {
        try {
            val alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            mediaPlayer = MediaPlayer().apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build()
                )
                setDataSource(this@AlarmActivity, alarmUri)
                isLooping = true
                prepare()
                start()
            }
        } catch (e: Exception) {
            Log.e("ALARM_DEBUG", "Error playing alarm sound", e)
        }
    }

    private fun startVibration(isSOS: Boolean) {
        vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            vibratorManager.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }

        vibrator?.let {
            val pattern = if (isSOS) longArrayOf(0, 1000, 200) else longArrayOf(0, 500, 500)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                it.vibrate(VibrationEffect.createWaveform(pattern, 0))
            } else {
                @Suppress("DEPRECATION")
                it.vibrate(pattern, 0)
            }
        }
    }

    private fun stopAlarm() {
        mediaPlayer?.let {
            if (it.isPlaying) it.stop()
            it.release()
        }
        mediaPlayer = null
        vibrator?.cancel()
        finish()
    }

    override fun onDestroy() {
        super.onDestroy()
        mediaPlayer?.release()
        mediaPlayer = null
        vibrator?.cancel()
    }

    override fun onBackPressed() {
        // Disable back button to force user to use the 'STOP' button
    }
}
