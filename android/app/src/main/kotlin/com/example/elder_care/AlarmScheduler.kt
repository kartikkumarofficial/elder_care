package com.example.elder_care

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
import androidx.core.app.AlarmManagerCompat
import org.json.JSONArray
import org.json.JSONObject
import java.util.Calendar

object AlarmScheduler {
    private const val TAG = "AlarmScheduler"
    private const val PREFS_NAME = "elder_care_alarms"
    private const val KEY_ALARMS = "active_alarms"

    @JvmStatic
    fun schedule(
        context: Context, 
        alarmId: String, 
        triggerTime: Long, 
        title: String, 
        dosage: String? = null, 
        instructions: String? = null,
        repeatType: String = "none", 
        repeatDays: List<String> = emptyList()
    ) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (!alarmManager.canScheduleExactAlarms()) {
                Log.w(TAG, "Cannot schedule exact alarms. Requesting permission.")
                val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                    data = Uri.parse("package:${context.packageName}")
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                context.startActivity(intent)
                // We proceed anyway, but it might not be exact if permission is denied.
                // However, for a medication app, we should ideally wait or prompt better.
            }
        }

        // Persist alarm data for reboot recovery
        saveAlarm(context, alarmId, triggerTime, title, dosage, instructions, repeatType, repeatDays)

        val intent = Intent(context, AlarmReceiver::class.java).apply {
            putExtra("alarm_id", alarmId)
            putExtra("alarm_title", title)
            putExtra("dosage", dosage)
            putExtra("instructions", instructions)
            putExtra("type", "ALARM_TRIGGER")
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            alarmId.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Using setAlarmClock is the most reliable way for "Clock-like" alarms
        val info = AlarmManager.AlarmClockInfo(triggerTime, pendingIntent)
        try {
            alarmManager.setAlarmClock(info, pendingIntent)
            Log.d(TAG, "Alarm scheduled using setAlarmClock for $alarmId at $triggerTime ($title)")
        } catch (e: SecurityException) {
            Log.e(TAG, "SecurityException scheduling alarm", e)
            // Fallback to less exact methods if setAlarmClock fails due to permissions (unlikely if declared)
            AlarmManagerCompat.setExactAndAllowWhileIdle(
                alarmManager,
                AlarmManager.RTC_WAKEUP,
                triggerTime,
                pendingIntent
            )
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
            alarmId.hashCode() + 1,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // For advance notifications, we don't need setAlarmClock, setAndAllowWhileIdle is enough
        AlarmManagerCompat.setAndAllowWhileIdle(
            alarmManager,
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
        
        removeAlarm(context, alarmId)
        Log.d(TAG, "Alarm and advance notification canceled for $alarmId")
    }

    @JvmStatic
    fun rescheduleAll(context: Context) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val alarmsJson = prefs.getString(KEY_ALARMS, "[]")
        val alarmsArray = JSONArray(alarmsJson)
        
        Log.d(TAG, "Rescheduling ${alarmsArray.length()} alarms after boot/update")
        
        val now = System.currentTimeMillis()
        
        for (i in 0 until alarmsArray.length()) {
            val alarm = alarmsArray.getJSONObject(i)
            val id = alarm.getString("id")
            val title = alarm.getString("title")
            val dosage = if (alarm.has("dosage")) alarm.getString("dosage") else null
            val instructions = if (alarm.has("instructions")) alarm.getString("instructions") else null
            var triggerTime = alarm.getLong("time")
            val repeatType = alarm.getString("repeatType")
            
            // If it's in the past and not recurring, skip or update
            if (triggerTime < now) {
                if (repeatType == "none") {
                    continue 
                } else {
                    triggerTime = calculateNextOccurrence(triggerTime, repeatType, alarm.getJSONArray("repeatDays"))
                }
            }
            
            schedule(
                context, 
                id, 
                triggerTime, 
                title, 
                dosage, 
                instructions, 
                repeatType, 
                jsonArrayToList(alarm.getJSONArray("repeatDays"))
            )
            
            val advanceTime = triggerTime - (10 * 60 * 1000)
            if (advanceTime > now) {
                scheduleAdvanceNotification(context, id, advanceTime, title)
            }
        }
    }

    private fun calculateNextOccurrence(lastTime: Long, repeatType: String, repeatDays: JSONArray): Long {
        val calendar = Calendar.getInstance()
        calendar.timeInMillis = lastTime
        
        val now = System.currentTimeMillis()
        when (repeatType) {
            "daily" -> {
                while (calendar.timeInMillis <= now) {
                    calendar.add(Calendar.DAY_OF_YEAR, 1)
                }
            }
            "weekly" -> {
                while (calendar.timeInMillis <= now) {
                    calendar.add(Calendar.WEEK_OF_YEAR, 1)
                }
            }
            "custom" -> {
                val daysList = jsonArrayToList(repeatDays).map { it.lowercase() }
                while (calendar.timeInMillis <= now || !isDayMatch(calendar, daysList)) {
                    calendar.add(Calendar.DAY_OF_YEAR, 1)
                }
            }
        }
        return calendar.timeInMillis
    }

    private fun isDayMatch(calendar: Calendar, days: List<String>): Boolean {
        val dayOfWeek = when (calendar.get(Calendar.DAY_OF_WEEK)) {
            Calendar.MONDAY -> "mon"
            Calendar.TUESDAY -> "tue"
            Calendar.WEDNESDAY -> "wed"
            Calendar.THURSDAY -> "thu"
            Calendar.FRIDAY -> "fri"
            Calendar.SATURDAY -> "sat"
            Calendar.SUNDAY -> "sun"
            else -> ""
        }
        return days.contains(dayOfWeek)
    }

    private fun saveAlarm(
        context: Context, 
        id: String, 
        time: Long, 
        title: String, 
        dosage: String?, 
        instructions: String?, 
        repeatType: String, 
        repeatDays: List<String>
    ) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val alarmsJson = prefs.getString(KEY_ALARMS, "[]")
        val alarmsArray = JSONArray(alarmsJson)
        
        val filtered = JSONArray()
        for (i in 0 until alarmsArray.length()) {
            val a = alarmsArray.getJSONObject(i)
            if (a.getString("id") != id) {
                filtered.put(a)
            }
        }
        
        val newAlarm = JSONObject().apply {
            put("id", id)
            put("time", time)
            put("title", title)
            put("dosage", dosage)
            put("instructions", instructions)
            put("repeatType", repeatType)
            put("repeatDays", JSONArray(repeatDays))
        }
        filtered.put(newAlarm)
        
        prefs.edit().putString(KEY_ALARMS, filtered.toString()).apply()
    }

    private fun removeAlarm(context: Context, id: String) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val alarmsJson = prefs.getString(KEY_ALARMS, "[]")
        val alarmsArray = JSONArray(alarmsJson)
        
        val filtered = JSONArray()
        for (i in 0 until alarmsArray.length()) {
            val a = alarmsArray.getJSONObject(i)
            if (a.getString("id") != id) {
                filtered.put(a)
            }
        }
        prefs.edit().putString(KEY_ALARMS, filtered.toString()).apply()
    }

    private fun jsonArrayToList(array: JSONArray): List<String> {
        val list = mutableListOf<String>()
        for (i in 0 until array.length()) {
            list.add(array.getString(i))
        }
        return list
    }
}
