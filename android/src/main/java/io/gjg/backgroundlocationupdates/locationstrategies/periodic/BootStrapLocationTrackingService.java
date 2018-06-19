package io.gjg.backgroundlocationupdates.locationstrategies.periodic;

import android.app.job.JobParameters;
import android.app.job.JobService;
import android.content.Context;

import io.gjg.backgroundlocationupdates.BackgroundLocationUpdatesPlugin;
import io.gjg.backgroundlocationupdates.locationstrategies.periodic.PeriodicLocationTracker;

public class BootStrapLocationTrackingService extends JobService {
    @Override
    public boolean onStopJob(JobParameters jobParameters) {
        return false;
    }

    @Override
    public boolean onStartJob(JobParameters jobParameters) {
        Integer requestInterval = getApplicationContext().getSharedPreferences(BackgroundLocationUpdatesPlugin.SHARED_PREFS, Context.MODE_PRIVATE)
                .getInt(BackgroundLocationUpdatesPlugin.KEY_PERSISTED_REQUEST_INTERVAL, -1);
        if (requestInterval == -1) {
            return false;
        }
        PeriodicLocationTracker.scheduleLocationTracking(requestInterval);
        return false;
    }
}
