package io.gjg.backgroundlocationupdates;

import android.app.Activity;
import android.arch.lifecycle.Observer;
import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import androidx.work.WorkStatus;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.gjg.backgroundlocationupdates.locationstrategies.broadcast.LocationUpdatesBroadcastReceiver;
import io.gjg.backgroundlocationupdates.locationstrategies.periodic.PeriodicLocationTracker;
import io.gjg.backgroundlocationupdates.persistence.LocationDatabase;
import io.gjg.backgroundlocationupdates.persistence.LocationEntity;

/** BackgroundLocationUpdatesPlugin */
@SuppressWarnings("unchecked")
public class BackgroundLocationUpdatesPlugin implements MethodCallHandler, EventChannel.StreamHandler {
  public static String KEY_PERSISTED_REQUEST_INTERVAL = "io.gjg.backgroundlocationupdates/RequestInterval";
  public static String SHARED_PREFS = "io.gjg.prefs";
  private Context mContext;
  private Activity mActivity;
  private EventChannel.EventSink isTrackingActiveEventSink;

  private BackgroundLocationUpdatesPlugin(Registrar registrar) {
    this.mContext = registrar.context();
    this.mActivity = registrar.activity();
    new EventChannel(registrar.messenger(), "plugins.gjg.io/background_location_updates/tracking_state")
        .setStreamHandler(this);

    RequestPermissionsHandler requestPermissionsHandler = new RequestPermissionsHandler(mContext);
    registrar.addRequestPermissionsResultListener(requestPermissionsHandler);
    new EventChannel(registrar.messenger(), "plugins.gjg.io/background_location_updates/permission_state")
      .setStreamHandler(requestPermissionsHandler);


  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "plugins.gjg.io/background_location_updates");
    channel.setMethodCallHandler(new BackgroundLocationUpdatesPlugin(registrar));
  }


  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("trackStart/android-strategy:periodic")) {
      startTrackingWithPeriodicStrategy(call, result);
    } else if (call.method.equals("trackStop/android-strategy:periodic")) {
      stopTrackingWithPeriodicStrategy(result);
    } else if (call.method.equals("trackStart/android-strategy:broadcast")) {
      startTrackingWithBroadcastStrategy(call);
    } else if (call.method.equals("trackStop/android-strategy:broadcast")) {
      stopTrackingWithBroadcastStrategy();
    } else if (call.method.equals("getLocationTracesCount")) {
      getAllLocationTracesCount(result);
    } else if (call.method.equals("getUnreadLocationTracesCount")) {
      getUnreadLocationTracesCount(result);
    } else if (call.method.equals("getUnreadLocationTraces")) {
      getAllUnreadLocationTraces(result);
    } else if (call.method.equals("getLocationTraces")) {
      getAllLocationTraces(result);
    } else if (call.method.equals("markAsRead")) {
      markLocationTracesAsRead(call, result);
    } else if (call.method.equals("requestPermission")) {
      requestPermission(result);
    } else if (call.method.equals("getSqliteDatabasePath")) {
      getSqliteDatabasePath(result);
    } else {
      result.notImplemented();
    }
  }

  private void getSqliteDatabasePath(Result result) {
    String path = mContext.getDatabasePath("locations").getAbsolutePath();
    result.success(path);
  }


  private void stopTrackingWithPeriodicStrategy(Result result) {
    PeriodicLocationTracker.stopLocationTracking();
    locationTrackingStopped();
    result.success(null);
  }

  private void startTrackingWithPeriodicStrategy(MethodCall call, Result result) {
    Integer requestInterval = extractAndPersistRequestInterval(call);
    locationTrackingStarted(requestInterval);
    PeriodicLocationTracker.stopLocationTracking();
    PeriodicLocationTracker.scheduleLocationTracking(requestInterval);
    result.success(true);
  }

  private void startTrackingWithBroadcastStrategy(MethodCall call) {
    Integer requestInterval = extractAndPersistRequestInterval(call);
    locationTrackingStarted(requestInterval);
    LocationUpdatesBroadcastReceiver.startTrackingBroadcastBased(mContext, requestInterval);
  }

  private void stopTrackingWithBroadcastStrategy() {
    locationTrackingStopped();
    LocationUpdatesBroadcastReceiver.stopTrackingBroadcastBased(mContext);
  }


  private void locationTrackingStopped() {
    isTrackingActiveEventSink.success(false);
    mContext.getSharedPreferences(BackgroundLocationUpdatesPlugin.SHARED_PREFS, Context.MODE_PRIVATE)
            .edit()
            .remove(KEY_PERSISTED_REQUEST_INTERVAL)
            .apply();
  }

  private void locationTrackingStarted(int requestInterval) {
    isTrackingActiveEventSink.success(true);
    mContext.getSharedPreferences(BackgroundLocationUpdatesPlugin.SHARED_PREFS, Context.MODE_PRIVATE)
            .edit()
            .putInt(BackgroundLocationUpdatesPlugin.KEY_PERSISTED_REQUEST_INTERVAL, requestInterval)
            .apply();
  }


  private void requestPermission(Result result) {
    if (mActivity != null) {
      boolean dialogShown = PeriodicLocationTracker.requestPermission(mActivity);
      result.success(dialogShown);
    } else {
      result.success(false);
    }
  }

  private void markLocationTracesAsRead(MethodCall call, Result result) {
    List<?> arguments = (List<?>) call.arguments;
    List<List<Integer>> locationIds = Utils.chopIntoParts((List<Integer>) arguments.get(0), 900);
    int affected = 0;
    for (List<Integer> chunk: locationIds) {
      affected += LocationDatabase.getLocationDatabase(mContext)
              .locationDao()
              .markAsRead(chunk);
    }
    result.success(affected);
  }

  private void getAllLocationTraces(Result result) {
    List<LocationEntity> locationEntities = LocationDatabase.getLocationDatabase(mContext)
            .locationDao()
            .getAll();
    List<Map<String, Double>> out = new ArrayList<>();
    for (LocationEntity locationEntity: locationEntities) {
      out.add(locationEntity.toMap());
    }
    result.success(out);
  }

  private void getAllUnreadLocationTraces(Result result) {
    List<LocationEntity> locationEntities = LocationDatabase.getLocationDatabase(mContext)
      .locationDao()
      .getUnread();
    List<Map<String, Double>> out = new ArrayList<>();
    for (LocationEntity locationEntity: locationEntities) {
      out.add(locationEntity.toMap());
    }
    result.success(out);
  }

  private void getUnreadLocationTracesCount(Result result) {
    int traces = LocationDatabase.getLocationDatabase(mContext)
            .locationDao()
            .countLocationTracesUnread();
    result.success(traces);
  }

  private void getAllLocationTracesCount(Result result) {
    int traces = LocationDatabase.getLocationDatabase(mContext)
            .locationDao()
            .countLocationTraces();
    result.success(traces);
  }


  @NonNull
  private Integer extractAndPersistRequestInterval(MethodCall call) {
    ArrayList<?> arguments = (ArrayList<?>) call.arguments;
    Integer requestInterval = (Integer) arguments.get(0);
    return requestInterval;
  }

  @Override
  public void onListen(Object o, EventChannel.EventSink eventSink) {
    if (mContext.getSharedPreferences(SHARED_PREFS, Context.MODE_PRIVATE).contains(KEY_PERSISTED_REQUEST_INTERVAL)) {
      eventSink.success(true);
    } else {
      eventSink.success(false);
    }
    this.isTrackingActiveEventSink = eventSink;
  }

  @Override
  public void onCancel(Object o) {
    this.isTrackingActiveEventSink = null;
  }
}
