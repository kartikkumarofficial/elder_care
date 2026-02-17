package com.example.elder_care;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class AlarmReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {

        Intent i = new Intent(context, AlarmActivity.class);
        i.putExtra("alarm_id", intent.getStringExtra("alarm_id"));
        i.putExtra("alarm_title", "Medicine Reminder");

        i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK |
                Intent.FLAG_ACTIVITY_CLEAR_TOP);

        context.startActivity(i);
    }
}
