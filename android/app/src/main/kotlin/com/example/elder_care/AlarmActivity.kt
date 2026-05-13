package com.example.elder_care

import android.app.Activity
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Build
import android.os.Bundle
import android.os.VibrationEffect
import android.os.Vibrator
import android.util.Log
import android.view.View
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

        setContentView(R.layout.activity_alarm)

        // 🔥 Bind views AFTER setContentView
        tvTime = findViewById<TextView>(R.id.tvTime)
        tvDate = findViewById<TextView>(R.id.tvDate)
        tvTitle = findViewById<TextView>(R.id.tvTitle)
        btnStop = findViewById<Button>(R.id.btnStop)

        // 🔥 Wake screen properly
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        }

        getWindow().addFlags(
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
        )

        // 🔥 Set Current Time & Date
        val now = Date()

        val timeFormat =
            SimpleDateFormat("HH:mm", Locale.getDefault())

        val dateFormat =
            SimpleDateFormat("EEEE, MMM dd", Locale.getDefault())

        tvTime!!.setText(timeFormat.format(now))
        tvDate!!.setText(dateFormat.format(now))

        // 🔥 Get Alarm Title from Intent
        val alarmTitle = getIntent().getStringExtra("alarm_title")

        if (alarmTitle != null && !alarmTitle.isEmpty()) {
            tvTitle!!.setText(alarmTitle)
        } else {
            tvTitle!!.setText("Medicine Reminder")
        }

        startAlarmSound()
        startVibration()

        btnStop!!.setOnClickListener(View.OnClickListener { v: View? -> stopAlarm() })
    }

    private fun startAlarmSound() {
        try {
            val alarmUri = RingtoneManager
                .getDefaultUri(RingtoneManager.TYPE_ALARM)

            mediaPlayer = MediaPlayer()

            mediaPlayer!!.setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
            )

            mediaPlayer!!.setDataSource(this, alarmUri)
            mediaPlayer!!.setLooping(true)
            mediaPlayer!!.prepare()
            mediaPlayer!!.start()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun startVibration() {
        vibrator = getSystemService(VIBRATOR_SERVICE) as Vibrator?

        if (vibrator != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator!!.vibrate(
                    VibrationEffect.createWaveform(
                        longArrayOf(0, 500, 500),
                        0
                    )
                )
            } else {
                vibrator!!.vibrate(longArrayOf(0, 500, 500), 0)
            }
        }
    }

    private fun stopAlarm() {
        if (mediaPlayer != null) {
            if (mediaPlayer!!.isPlaying()) {
                mediaPlayer!!.stop()
            }
            mediaPlayer!!.release()
            mediaPlayer = null
        }

        if (vibrator != null) {
            vibrator!!.cancel()
        }

        finish()
    }

    override fun onDestroy() {
        super.onDestroy()

        if (mediaPlayer != null) {
            mediaPlayer!!.release()
            mediaPlayer = null
        }

        if (vibrator != null) {
            vibrator!!.cancel()
        }
    }
}
