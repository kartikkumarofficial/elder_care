package com.example.elder_care;

import android.app.Activity;
import android.content.Context;
import android.media.AudioAttributes;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.VibrationEffect;
import android.os.Vibrator;
import android.view.WindowManager;
import android.widget.Button;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;


public class AlarmActivity extends Activity {

    private MediaPlayer mediaPlayer;
    private Vibrator vibrator;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_alarm);

        // ==========================
        // 🔥 Wake Screen (All Versions)
        // ==========================
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true);
            setTurnScreenOn(true);
        }

        getWindow().addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED |
                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON |
                        WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
        );

        // ==========================
        // 🔥 Start Alarm Sound (MediaPlayer)
        // ==========================
        try {

            Uri alarmUri = android.media.RingtoneManager
                    .getDefaultUri(android.media.RingtoneManager.TYPE_ALARM);

            mediaPlayer = new MediaPlayer();

            mediaPlayer.setAudioAttributes(
                    new AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_ALARM)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .build()
            );

            mediaPlayer.setDataSource(this, alarmUri);
            mediaPlayer.setLooping(true); // 🔥 Important
            mediaPlayer.prepare();
            mediaPlayer.start();

        } catch (Exception e) {
            e.printStackTrace();
        }

        // ==========================
        // 🔥 Start Vibration (Looping)
        // ==========================
        vibrator = (Vibrator) getSystemService(Context.VIBRATOR_SERVICE);

        if (vibrator != null) {

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator.vibrate(
                        VibrationEffect.createWaveform(
                                new long[]{0, 500, 500},
                                0 // repeat index
                        )
                );
            } else {
                vibrator.vibrate(new long[]{0, 500, 500}, 0);
            }
        }

        // ==========================
        // 🔥 Stop Button
        // ==========================
        Button stopButton = findViewById(R.id.stopButton);
        stopButton.setOnClickListener(v -> stopAlarm());
    }

    // ==========================
    // 🔥 Stop Alarm Cleanly
    // ==========================
    private void stopAlarm() {

        try {

            String alarmId = getIntent().getStringExtra("alarm_id");

            if (alarmId != null) {
                acknowledgeAlarm(alarmId);
            }

            if (mediaPlayer != null) {
                if (mediaPlayer.isPlaying()) {
                    mediaPlayer.stop();
                }
                mediaPlayer.release();
                mediaPlayer = null;
            }

            if (vibrator != null) {
                vibrator.cancel();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        finish();
    }
    private void acknowledgeAlarm(String alarmId) {

        new Thread(() -> {
            try {

                URL url = new URL("https://YOUR_PROJECT_ID.supabase.co/rest/v1/alarm_instances?id=eq." + alarmId);

                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                conn.setRequestMethod("PATCH");

                conn.setRequestProperty("apikey", "YOUR_SERVICE_ROLE_OR_ANON_KEY");
                conn.setRequestProperty("Authorization", "Bearer YOUR_SERVICE_ROLE_OR_ANON_KEY");
                conn.setRequestProperty("Content-Type", "application/json");

                conn.setDoOutput(true);

                String jsonInputString = "{ \"status\": \"acknowledged\", \"acknowledged_at\": \"" + new java.util.Date().toInstant().toString() + "\" }";

                try (OutputStream os = conn.getOutputStream()) {
                    byte[] input = jsonInputString.getBytes("utf-8");
                    os.write(input, 0, input.length);
                }

                conn.getResponseCode();

            } catch (Exception e) {
                e.printStackTrace();
            }
        }).start();
    }



    // ==========================
    // 🔥 Safety Stop
    // ==========================
    @Override
    protected void onDestroy() {
        super.onDestroy();
        stopAlarm();
    }
}
