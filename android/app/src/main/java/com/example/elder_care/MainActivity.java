package com.example.elder_care;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "eldercare/alarm";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                CHANNEL
        ).setMethodCallHandler((call, result) -> {

            if (call.method.equals("scheduleAlarm")) {

                String alarmId = call.argument("alarmId");
                long triggerTime = call.argument("triggerTime");

                AlarmScheduler.schedule(
                        this,
                        alarmId,
                        triggerTime
                );

                result.success(null);
            }

            else if (call.method.equals("cancelAlarm")) {

                String alarmId = call.argument("alarmId");

                AlarmScheduler.cancel(this, alarmId);

                result.success(null);
            }

            else {
                result.notImplemented();
            }
        });
    }
}
