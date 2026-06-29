package com.example.elder_care

import android.app.Activity
import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class AlarmActivity : Activity() {
    private var tvTime: TextView? = null
    private var tvDate: TextView? = null
    private var tvTitle: TextView? = null
    private var tvDosage: TextView? = null
    private var tvInstructions: TextView? = null
    private var btnStop: Button? = null
    private var btnSnooze: Button? = null
    private var btnTake: Button? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val alarmId = intent.getStringExtra("alarm_id") ?: "unknown"
        Log.d("ALARM_DEBUG", "🚀 AlarmActivity launched for ID: $alarmId")

        // Professional Unlock & Wake Screen logic for Alarms
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
            val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
            keyguardManager.requestDismissKeyguard(this, null)
        } else {
            @Suppress("DEPRECATION")
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
        tvDosage = findViewById(R.id.tvDosage)
        tvInstructions = findViewById(R.id.tvInstructions)
        btnStop = findViewById(R.id.btnStop)
        btnSnooze = findViewById(R.id.btnSnooze)
        btnTake = findViewById(R.id.btnTake)

        val now = Date()
        val timeFormat = SimpleDateFormat("HH:mm", Locale.getDefault())
        val dateFormat = SimpleDateFormat("EEEE, MMM dd", Locale.getDefault())

        tvTime?.text = timeFormat.format(now)
        tvDate?.text = dateFormat.format(now)

        val alarmTitle = intent.getStringExtra("alarm_title")
        val dosage = intent.getStringExtra("dosage")
        val instructions = intent.getStringExtra("instructions")
        val isSOS = intent.getBooleanExtra("is_sos", false)

        if (isSOS) {
            tvTitle?.text = "EMERGENCY ALERT (SOS)"
            tvTitle?.setTextColor(0xFFFF0000.toInt())
            btnSnooze?.visibility = android.view.View.GONE
            btnTake?.visibility = android.view.View.GONE
        } else {
            if (!alarmTitle.isNullOrEmpty()) {
                tvTitle?.text = alarmTitle
            }
            if (!dosage.isNullOrEmpty()) {
                tvDosage?.text = dosage
                tvDosage?.visibility = android.view.View.VISIBLE
            }
            if (!instructions.isNullOrEmpty()) {
                tvInstructions?.text = instructions
                tvInstructions?.visibility = android.view.View.VISIBLE
            }
        }

        btnStop?.setOnClickListener {
            Log.d("ALARM_DEBUG", "Alarm dismissed by user")
            stopAlarm()
        }

        btnSnooze?.setOnClickListener {
            Log.d("ALARM_DEBUG", "Alarm snoozed (10 mins)")
            val snoozeTime = System.currentTimeMillis() + (10 * 60 * 1000)
            AlarmScheduler.schedule(
                this, 
                "snooze_$alarmId", 
                snoozeTime, 
                "Snoozed: $alarmTitle",
                dosage,
                instructions
            )
            stopAlarm()
        }

        btnTake?.setOnClickListener {
            Log.d("ALARM_DEBUG", "Medication marked as TAKEN")
            // Here you could send a broadcast to Flutter to update Supabase
            stopAlarm()
        }
    }

    private fun stopAlarm() {
        val stopServiceIntent = Intent(this, AlarmService::class.java).apply {
            action = AlarmService.ACTION_STOP_ALARM
        }
        startService(stopServiceIntent)
        finish()
    }

    override fun onBackPressed() {
        // Force button use to stop alarm
    }
}
