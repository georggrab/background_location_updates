package io.gjg.backgroundlocationupdates;

import android.Manifest;
import android.app.Activity;
import android.arch.lifecycle.LiveData;
import android.content.Context;
import android.content.pm.PackageManager;
import android.location.Location;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.util.Log;

import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.tasks.Tasks;

import java.util.Calendar;
import java.util.List;
import java.util.concurrent.TimeUnit;

import androidx.work.Data;
import androidx.work.ExistingWorkPolicy;
import androidx.work.OneTimeWorkRequest;
import androidx.work.WorkManager;
import androidx.work.WorkStatus;
import androidx.work.Worker;
import io.gjg.backgroundlocationupdates.persistence.LocationDatabase;
import io.gjg.backgroundlocationupdates.persistence.LocationEntity;


public class LocationManagerController extends Worker {
    private static final int PERMISSION_REQUEST_FINE_LOCATION = 0x0424242;
    private static final String TRACK_IDENT = LocationManagerController.class.getSimpleName();
    private static final String TAG = LocationManagerController.class.getSimpleName();
    private FusedLocationProviderClient mClient;
    private LocationDatabase mLocationDatabase;

    public static boolean scheduleLocationTracking(int requestInterval) {
        OneTimeWorkRequest request = new OneTimeWorkRequest.Builder(LocationManagerController.class)
                .setInitialDelay(requestInterval, TimeUnit.MILLISECONDS)
                .setInputData(
                        new Data.Builder()
                                .putInt("requestInterval", requestInterval)
                                .build())
                .addTag(TRACK_IDENT)
                .build();
        WorkManager.getInstance().beginUniqueWork(TRACK_IDENT, ExistingWorkPolicy.REPLACE, request).enqueue();
        return true;
    }

    public static LiveData<List<WorkStatus>> isLocationTrackingActive() {
        return WorkManager.getInstance().getStatusesForUniqueWork(TRACK_IDENT);
    }

    public static void stopLocationTracking() {
        WorkManager.getInstance().cancelUniqueWork(TRACK_IDENT);
    }

    public static void requestPermission(Context context) {
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED ||
                ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions((Activity) context, new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, PERMISSION_REQUEST_FINE_LOCATION);
        }
    }

    @NonNull
    @Override
    public WorkerResult doWork() {
        try {
            Data input = getInputData();
            if (mClient == null) {
                mClient = new FusedLocationProviderClient(getApplicationContext());
            }
            if (mLocationDatabase == null) {
                mLocationDatabase = LocationDatabase.getLocationDatabase(getApplicationContext());
            }
            Location result = Tasks.await(mClient.getLastLocation());
            this.mLocationDatabase.locationDao().insertAll(new LocationEntity(
                    result.getAccuracy(),
                    result.getLongitude(),
                    result.getLatitude(),
                    result.getAltitude(),
                    Calendar.getInstance().getTimeInMillis(),
                    0
            ));
            Log.i(TAG, String.format("Location Traces: %d, Unread Location Traces: %d",
                    this.mLocationDatabase.locationDao().countLocationTraces(),
                    this.mLocationDatabase.locationDao().countLocationTracesUnread()));
            LocationManagerController.scheduleLocationTracking(
                    input.getInt("requestInterval", 10000));
            return WorkerResult.SUCCESS;
        } catch (Exception e) {
            Log.e(TAG, e.getLocalizedMessage(), e);
            return WorkerResult.RETRY;
        }
    }
}
