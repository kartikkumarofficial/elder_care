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
            flutterEngine.getDartExecutor().getBinaryMessenger(),
            CHANNEL
        ).setMethodCallHandler(MethodCallHandler { call: MethodCall?, result: MethodChannel.Result? ->
            if (call!!.method == "scheduleAlarm") {
                val alarmId = call.argument<String?>("alarmId")
                val triggerTime: Long = call.argument<Long?>("triggerTime")!!

                AlarmScheduler.schedule(
                    this,
                    alarmId!!,
                    triggerTime
                )

                result!!.success(null)
            } else if (call.method == "cancelAlarm") {
                val alarmId = call.argument<String?>("alarmId")

                AlarmScheduler.cancel(this, alarmId!!)

                result!!.success(null)
            } else {
                result!!.notImplemented()
            }
        })
    }

    companion object {
        private const val CHANNEL = "eldercare/alarm"
    }
}
