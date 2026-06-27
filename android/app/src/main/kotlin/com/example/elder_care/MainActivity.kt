package com.example.elder_care

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleAlarm" -> {
                    val alarmId = call.argument<String>("alarmId")
                    val triggerTime = call.argument<Long>("triggerTime")
                    val title = call.argument<String>("title") ?: "Task Reminder"

                    if (alarmId != null && triggerTime != null) {
                        AlarmScheduler.schedule(this, alarmId, triggerTime, title)
                        
                        // Also schedule advance notification 10 mins before
                        val advanceTime = triggerTime - (10 * 60 * 1000)
                        if (advanceTime > System.currentTimeMillis()) {
                            AlarmScheduler.scheduleAdvanceNotification(this, alarmId, advanceTime, title)
                        }
                        
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENTS", "alarmId or triggerTime was null", null)
                    }
                }
                "cancelAlarm" -> {
                    val alarmId = call.argument<String>("alarmId")
                    if (alarmId != null) {
                        AlarmScheduler.cancel(this, alarmId)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENTS", "alarmId was null", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    companion object {
        private const val CHANNEL = "eldercare/alarm"
    }
}
