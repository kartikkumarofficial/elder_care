package com.example.elder_care;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Build;

import androidx.core.app.NotificationCompat;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

public class MyFirebaseMessagingService extends FirebaseMessagingService {

    private static final String ALARM_CHANNEL = "alarm_channel";
    private static final String MISSED_CHANNEL = "missed_channel";

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {

        android.util.Log.d("FCM_DEBUG", "Message received!");
        android.util.Log.d("FCM_DEBUG", "Data: " + remoteMessage.getData());
        android.util.Log.d("FCM_DEBUG", "Notification: " + remoteMessage.getNotification());

        createChannels();

        // Handle DATA payload
        if (remoteMessage.getData().size() > 0) {

            String type = remoteMessage.getData().get("type");
            String alarmId = remoteMessage.getData().get("alarm_id");

            android.util.Log.d("FCM_DEBUG", "Type: " + type);
            android.util.Log.d("FCM_DEBUG", "AlarmId: " + alarmId);

            if ("alarm".equals(type)) {
                showFullScreenAlarm(alarmId);
            }

            if ("alarm_missed".equals(type)) {
                showMissedNotification(alarmId);
            }
        }

        // Handle NOTIFICATION payload (important when app is killed)
        if (remoteMessage.getNotification() != null) {
            android.util.Log.d("FCM_DEBUG", "Notification title: "
                    + remoteMessage.getNotification().getTitle());
        }
    }


    private void showFullScreenAlarm(String alarmId) {

        Intent intent = new Intent(this, AlarmActivity.class);
        intent.putExtra("alarm_id", alarmId);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);

        PendingIntent fullScreenIntent = PendingIntent.getActivity(
                this,
                alarmId.hashCode(),
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );

        NotificationCompat.Builder builder =
                new NotificationCompat.Builder(this, ALARM_CHANNEL)
                        .setSmallIcon(R.mipmap.ic_launcher)
                        .setContentTitle("Medicine Reminder")
                        .setContentText("Tap to respond")
                        .setPriority(NotificationCompat.PRIORITY_HIGH)
                        .setCategory(NotificationCompat.CATEGORY_ALARM)
                        .setFullScreenIntent(fullScreenIntent, true)
                        .setOngoing(true)
                        .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                        .setAutoCancel(false);

        NotificationManager manager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        manager.notify(alarmId.hashCode(), builder.build());
    }

    private void showMissedNotification(String alarmId) {

        Intent intent = new Intent(this, MainActivity.class);
        intent.putExtra("alarm_id", alarmId);

        PendingIntent pendingIntent = PendingIntent.getActivity(
                this,
                1,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );

        NotificationCompat.Builder builder =
                new NotificationCompat.Builder(this, MISSED_CHANNEL)
                        .setSmallIcon(R.mipmap.ic_launcher)
                        .setContentTitle("Missed Alarm")
                        .setContentText("Receiver did not respond")
                        .setPriority(NotificationCompat.PRIORITY_HIGH)
                        .setAutoCancel(true)
                        .setContentIntent(pendingIntent);

        NotificationManager manager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        manager.notify(1001, builder.build());
    }

    private void createChannels() {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

            NotificationManager manager =
                    getSystemService(NotificationManager.class);

            NotificationChannel alarmChannel =
                    new NotificationChannel(
                            ALARM_CHANNEL,
                            "Alarms",
                            NotificationManager.IMPORTANCE_HIGH
                    );

            alarmChannel.enableVibration(true);
            alarmChannel.setLockscreenVisibility(NotificationCompat.VISIBILITY_PUBLIC);
            alarmChannel.setSound(
                    android.provider.Settings.System.DEFAULT_ALARM_ALERT_URI,
                    new android.media.AudioAttributes.Builder()
                            .setUsage(android.media.AudioAttributes.USAGE_ALARM)
                            .build()
            );

            NotificationChannel missedChannel =
                    new NotificationChannel(
                            MISSED_CHANNEL,
                            "Missed Alarms",
                            NotificationManager.IMPORTANCE_HIGH
                    );

            manager.createNotificationChannel(alarmChannel);
            manager.createNotificationChannel(missedChannel);
        }
    }
}
