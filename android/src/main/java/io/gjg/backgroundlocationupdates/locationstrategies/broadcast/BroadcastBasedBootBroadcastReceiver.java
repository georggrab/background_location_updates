package io.gjg.backgroundlocationupdates.locationstrategies.broadcast;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import io.gjg.backgroundlocationupdates.BackgroundLocationUpdatesPlugin;

public class BroadcastBasedBootBroadcastReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        Integer requestInterval = context.getSharedPreferences(BackgroundLocationUpdatesPlugin.SHARED_PREFS, Context.MODE_PRIVATE)
                .getInt(BackgroundLocationUpdatesPlugin.KEY_PERSISTED_REQUEST_INTERVAL,  -1);
        if (requestInterval == -1) {
            return;
        }
        LocationUpdatesBroadcastReceiver.startTrackingBroadcastBased(
                context, requestInterval);
    }
}
