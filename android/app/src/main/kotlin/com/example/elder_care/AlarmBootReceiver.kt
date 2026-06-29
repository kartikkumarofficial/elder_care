package com.example.elder_care

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Receiver responsible for rescheduling alarms after system events.
 * Correctly handles:
 * - Boot Completed: Device restart.
 * - My Package Replaced: App update/reinstall.
 * - Time Set: Manual clock adjustment.
 * - Timezone Changed: User moved to another timezone.
 */
class AlarmBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        Log.d("AlarmBootReceiver", "🔔 System broadcast received: $action")
        
        // Audit of Intent constants:
        // Intent.ACTION_BOOT_COMPLETED = "android.intent.action.BOOT_COMPLETED"
        // Intent.ACTION_MY_PACKAGE_REPLACED = "android.intent.action.MY_PACKAGE_REPLACED"
        // Intent.ACTION_TIMEZONE_CHANGED = "android.intent.action.TIMEZONE_CHANGED"
        // Intent.ACTION_TIME_CHANGED = "android.intent.action.TIME_SET" (This is the one that replaces ACTION_TIME_SET)
        
        val validActions = listOf(
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_TIMEZONE_CHANGED,
            Intent.ACTION_TIME_CHANGED,
            "android.intent.action.QUICKBOOT_POWERON", // HTC/Samsung fast boot
            "com.htc.intent.action.QUICKBOOT_POWERON"
        )

        if (validActions.contains(action)) {
            Log.i("AlarmBootReceiver", "♻️ Triggering alarm rescheduling for reliability.")
            AlarmScheduler.rescheduleAll(context)
        }
    }
}
