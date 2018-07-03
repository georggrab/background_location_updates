package io.gjg.backgroundlocationupdates.locationstrategies.broadcast;

import android.annotation.SuppressLint;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.location.Location;
import android.util.Log;

import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationResult;
import com.google.android.gms.location.LocationServices;

import java.util.ArrayList;
import java.util.List;

import io.gjg.backgroundlocationupdates.persistence.LocationDatabase;
import io.gjg.backgroundlocationupdates.persistence.LocationEntity;
import io.gjg.backgroundlocationupdates.persistence.TraceInserter;

public class LocationUpdatesBroadcastReceiver extends BroadcastReceiver {
    private static final String TAG = LocationUpdatesBroadcastReceiver.class.getSimpleName();

    public static final String ACTION_PROCESS_LOCATION_UPDATE = "io.gjg.backgroundlocationupdates" +
            ".ACTION_PROCESS_LOCATION_UPDATE";

    public static PendingIntent getPendingIntent(Context context) {
        Intent intent = new Intent(context, LocationUpdatesBroadcastReceiver.class);
        intent.setAction(LocationUpdatesBroadcastReceiver.ACTION_PROCESS_LOCATION_UPDATE);
        return PendingIntent.getBroadcast(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT);
    }

    @SuppressLint("MissingPermission")
    public static void startTrackingBroadcastBased(Context context, int requestInterval) {
        FusedLocationProviderClient client = LocationServices.getFusedLocationProviderClient(context);
        LocationRequest request = new LocationRequest();
        request.setInterval(requestInterval);
        request.setFastestInterval(requestInterval);
        request.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);
        client.requestLocationUpdates(request, LocationUpdatesBroadcastReceiver.getPendingIntent(context));
    }

    public static void stopTrackingBroadcastBased(Context context) {
        LocationServices.getFusedLocationProviderClient(context)
                .removeLocationUpdates(LocationUpdatesBroadcastReceiver.getPendingIntent(context));
    }


    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent != null) {
            final String action = intent.getAction();
            if (ACTION_PROCESS_LOCATION_UPDATE.equals(action)) {
                LocationResult result = LocationResult.extractResult(intent);
                if (result != null) {
                    List<Location> locations = result.getLocations();
                    LocationEntity[] locationEntities = new LocationEntity[locations.size()];
                    for (int i = 0; i < locations.size(); i++) {
                        locationEntities[i] = LocationEntity.fromAndroidLocation(locations.get(i));
                    }
                    new TraceInserter(context).execute(locationEntities);
                }
            }
        }
    }
}
