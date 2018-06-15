package io.gjg.backgroundlocationupdates.service;

import android.app.Service;
import android.app.job.JobParameters;
import android.app.job.JobService;

import io.gjg.backgroundlocationupdates.LocationManagerController;

public class BootStrapLocationTrackingService extends JobService {
    @Override
    public boolean onStopJob(JobParameters jobParameters) {
        return false;
    }

    @Override
    public boolean onStartJob(JobParameters jobParameters) {
        LocationManagerController.scheduleLocationTracking(10000);
        return false;
    }
}
