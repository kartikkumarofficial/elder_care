package com.example.elder_care

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val i = Intent(context, AlarmActivity::class.java)
        i.putExtra("alarm_id", intent.getStringExtra("alarm_id"))
        i.putExtra("alarm_title", "Medicine Reminder")

        i.addFlags(
            Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP
        )

        context.startActivity(i)
    }
}
