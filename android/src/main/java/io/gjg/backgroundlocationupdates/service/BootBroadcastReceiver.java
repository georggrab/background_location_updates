package io.gjg.backgroundlocationupdates.service;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class BootBroadcastReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        Intent startServiceIntent = new Intent(context, BootStrapLocationTrackingService.class);
        context.startService(startServiceIntent);
    }
}
