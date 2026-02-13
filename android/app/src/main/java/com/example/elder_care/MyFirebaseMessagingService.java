package com.example.elder_care;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;

import androidx.core.app.NotificationCompat;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

public class MyFirebaseMessagingService extends FirebaseMessagingService {

    private static final String TAG = "FCMService";
    private static final String CHANNEL_ID = "eldercare_notifications";
    private static final String ALARM_CHANNEL = "alarm_channel";
    private static final String MISSED_CHANNEL = "missed_channel";
    private static final String SOS_CHANNEL = "sos_channel";


    @Override
    public void onNewToken(String token) {
        super.onNewToken(token);
        Log.d(TAG, "FCM Token: " + token);

        // TODO:     Send token to Supabase via API
    }

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {

        if (remoteMessage.getData().size() > 0) {

            String type = remoteMessage.getData().get("type");
            String alarmId = remoteMessage.getData().get("alarm_id");

            if ("alarm".equals(type)) {
                launchAlarmActivity(alarmId);
            }

            if ("alarm_missed".equals(type)) {
                showMissedNotification(alarmId);
            }
            if ("sos".equals(type)) {
                launchSOSActivity(remoteMessage.getData().get("location"));
            }

        }
    }
    private void launchSOSActivity(String location) {

        Intent intent = new Intent(this, MainActivity.class);
        intent.putExtra("sos_location", location);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);

        startActivity(intent);
    }

    private void showMissedNotification(String alarmId) {

        createNotificationChannels();

        Intent intent = new Intent(this, MainActivity.class);
        intent.putExtra("alarm_id", alarmId);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);

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
                        .setContentText("Receiver did not respond in time.")
                        .setPriority(NotificationCompat.PRIORITY_HIGH)
                        .setAutoCancel(true)
                        .setContentIntent(pendingIntent);

        NotificationManager manager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        manager.notify(1001, builder.build());
    }




    private void showNotification(String title, String body) {
        createNotificationChannels();

        Intent intent = new Intent(this, MainActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);

        PendingIntent pendingIntent = PendingIntent.getActivity(
                this,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );

        NotificationCompat.Builder builder =
                new NotificationCompat.Builder(this, CHANNEL_ID)
                        .setSmallIcon(R.mipmap.ic_launcher)
                        .setContentTitle(title)
                        .setContentText(body)
                        .setPriority(NotificationCompat.PRIORITY_HIGH)
                        .setAutoCancel(true)
                        .setContentIntent(pendingIntent);

        NotificationManager manager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        manager.notify((int) System.currentTimeMillis(), builder.build());
    }

    private void createNotificationChannels() {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

            NotificationManager manager =
                    getSystemService(NotificationManager.class);

            NotificationChannel alarmChannel =
                    new NotificationChannel(
                            ALARM_CHANNEL,
                            "Alarms",
                            NotificationManager.IMPORTANCE_HIGH
                    );
            alarmChannel.setLockscreenVisibility(NotificationCompat.VISIBILITY_PUBLIC);

            NotificationChannel missedChannel =
                    new NotificationChannel(
                            MISSED_CHANNEL,
                            "Missed Alarms",
                            NotificationManager.IMPORTANCE_HIGH
                    );

            NotificationChannel sosChannel =
                    new NotificationChannel(
                            SOS_CHANNEL,
                            "SOS Alerts",
                            NotificationManager.IMPORTANCE_HIGH
                    );

            manager.createNotificationChannel(alarmChannel);
            manager.createNotificationChannel(missedChannel);
            manager.createNotificationChannel(sosChannel);
        }
    }



    private void launchAlarmActivity(String alarmId) {

        createNotificationChannels();

        // 🔥 Force open activity
        Intent activityIntent = new Intent(this, AlarmActivity.class);
        activityIntent.putExtra("alarm_id", alarmId);
        activityIntent.addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK |
                        Intent.FLAG_ACTIVITY_CLEAR_TOP
        );

        startActivity(activityIntent);

        // 🔥 Also show notification (for lock screen compliance)
        PendingIntent fullScreenPendingIntent = PendingIntent.getActivity(
                this,
                0,
                activityIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );

        NotificationCompat.Builder builder =
                new NotificationCompat.Builder(this, ALARM_CHANNEL)
                        .setSmallIcon(R.mipmap.ic_launcher)
                        .setContentTitle("Emergency Alarm")
                        .setContentText("Tap to respond")
                        .setPriority(NotificationCompat.PRIORITY_MAX)
                        .setCategory(NotificationCompat.CATEGORY_ALARM)
                        .setFullScreenIntent(fullScreenPendingIntent, true)
                        .setOngoing(true)
                        .setVisibility(NotificationCompat.VISIBILITY_PUBLIC);

        NotificationManager manager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        manager.notify(999, builder.build());
    }




}
