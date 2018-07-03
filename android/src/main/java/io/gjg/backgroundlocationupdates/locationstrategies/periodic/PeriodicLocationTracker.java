package io.gjg.backgroundlocationupdates.locationstrategies.periodic;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.arch.lifecycle.LiveData;
import android.content.Context;
import android.location.Location;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
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
import io.gjg.backgroundlocationupdates.RequestPermissionsHandler;
import io.gjg.backgroundlocationupdates.persistence.LocationDatabase;
import io.gjg.backgroundlocationupdates.persistence.LocationEntity;
import io.gjg.backgroundlocationupdates.persistence.TraceInserter;


public class PeriodicLocationTracker extends Worker {
    private static final String TRACK_IDENT = PeriodicLocationTracker.class.getSimpleName();
    private static final String TAG = PeriodicLocationTracker.class.getSimpleName();
    private FusedLocationProviderClient mClient;
    private LocationDatabase mLocationDatabase;

    public static boolean scheduleLocationTracking(int requestInterval) {
        OneTimeWorkRequest request = new OneTimeWorkRequest.Builder(PeriodicLocationTracker.class)
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

    public static void stopLocationTracking() {
        WorkManager.getInstance().cancelUniqueWork(TRACK_IDENT);
    }

    public static boolean requestPermission(Context context) {
        if (!RequestPermissionsHandler.hasPermission(context)) {
            ActivityCompat.requestPermissions((Activity) context, new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, RequestPermissionsHandler.PERMISSION_REQUEST_FINE_LOCATION);
            return true;
        }
        return false;
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
            @SuppressLint("MissingPermission") Location result = Tasks.await(mClient.getLastLocation());
            this.mLocationDatabase.locationDao().insertAll(LocationEntity.fromAndroidLocation(result));
            Log.i(TAG, String.format("Location Traces: %d, Unread Location Traces: %d",
                    this.mLocationDatabase.locationDao().countLocationTraces(),
                    this.mLocationDatabase.locationDao().countLocationTracesUnread()));
            PeriodicLocationTracker.scheduleLocationTracking(
                    input.getInt("requestInterval", 10000));
            return WorkerResult.SUCCESS;
        } catch (Exception e) {
            Log.e(TAG, e.getLocalizedMessage(), e);
            return WorkerResult.RETRY;
        }
    }
}
