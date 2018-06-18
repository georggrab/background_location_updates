package io.gjg.backgroundlocationupdates;

import android.app.Activity;
import android.arch.lifecycle.Observer;
import android.content.Context;
import android.support.annotation.Nullable;
import android.util.Log;

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
import io.gjg.backgroundlocationupdates.persistence.LocationDatabase;
import io.gjg.backgroundlocationupdates.persistence.LocationEntity;

/** BackgroundLocationUpdatesPlugin */
@SuppressWarnings("unchecked")
public class BackgroundLocationUpdatesPlugin implements MethodCallHandler, EventChannel.StreamHandler {
  public static String KEY_PERSISTED_REQUEST_INTERVAL = "io.gjg.backgroundlocationupdates/RequestInterval";
  public static String SHARED_PREFS = "io.gjg.prefs";
  private Context mContext;
  private Activity mActivity;
  private EventChannel.EventSink eventSink;
  private Observer stateObserver = new Observer<List<WorkStatus>>() {
    @Override
    public void onChanged(@Nullable List<WorkStatus> o) {
      if (eventSink != null && o != null) {
        if (o.size() > 0) {
          switch (o.get(0).getState()) {
            case CANCELLED:
            case SUCCEEDED:
            case BLOCKED:
              eventSink.success(false);
              break;
            case RUNNING:
            case ENQUEUED:
              eventSink.success(true);
              break;
          }
        }
      }
    }
  };

  private BackgroundLocationUpdatesPlugin(Registrar registrar) {
    this.mContext = registrar.context();
    this.mActivity = registrar.activity();
    new EventChannel(registrar.messenger(), "plugins.gjg.io/background_location_updates/tracking_state")
        .setStreamHandler(this);
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "plugins.gjg.io/background_location_updates");
    channel.setMethodCallHandler(new BackgroundLocationUpdatesPlugin(registrar));
  }

  public static <T>List<List<T>> chopIntoParts( final List<T> ls, final int iParts )
  {
    final List<List<T>> lsParts = new ArrayList<List<T>>();
    final int iChunkSize = ls.size() / iParts;
    int iLeftOver = ls.size() % iParts;
    int iTake = iChunkSize;

    for( int i = 0, iT = ls.size(); i < iT; i += iTake )
    {
      if( iLeftOver > 0 )
      {
        iLeftOver--;

        iTake = iChunkSize + 1;
      }
      else
      {
        iTake = iChunkSize;
      }

      lsParts.add( new ArrayList<T>( ls.subList( i, Math.min( iT, i + iTake ) ) ) );
    }

    return lsParts;
  }

  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("startTrackingLocation")) {
      ArrayList<?> arguments = (ArrayList<?>) call.arguments;
      Integer requestInterval = (Integer) arguments.get(1);
      mContext.getSharedPreferences(BackgroundLocationUpdatesPlugin.SHARED_PREFS, Context.MODE_PRIVATE)
              .edit()
              .putInt(BackgroundLocationUpdatesPlugin.KEY_PERSISTED_REQUEST_INTERVAL, requestInterval)
              .apply();
      LocationManagerController.stopLocationTracking();
      result.success(LocationManagerController.scheduleLocationTracking(requestInterval));
    } else if (call.method.equals("stopTrackingLocation")) {
      LocationManagerController.stopLocationTracking();
      result.success(null);
    } else if (call.method.equals("getLocationTracesCount")) {
      int traces = LocationDatabase.getLocationDatabase(mContext)
              .locationDao()
              .countLocationTraces();
      result.success(traces);
    } else if (call.method.equals("getUnreadLocationTracesCount")) {
      int traces = LocationDatabase.getLocationDatabase(mContext)
              .locationDao()
              .countLocationTracesUnread();
      result.success(traces);
    } else if (call.method.equals("getUnreadLocationTraces")) {
      List<LocationEntity> locationEntities = LocationDatabase.getLocationDatabase(mContext)
        .locationDao()
        .getUnread();
      List<Map<String, Double>> out = new ArrayList<>();
      for (LocationEntity locationEntity: locationEntities) {
        out.add(locationEntity.toMap());
      }
      result.success(out);
    } else if (call.method.equals("getLocationTraces")) {
      List<LocationEntity> locationEntities = LocationDatabase.getLocationDatabase(mContext)
              .locationDao()
              .getAll();
      List<Map<String, Double>> out = new ArrayList<>();
      for (LocationEntity locationEntity: locationEntities) {
        out.add(locationEntity.toMap());
      }
      result.success(out);
    } else if (call.method.equals("markAsRead")) {
      List<?> arguments = (List<?>) call.arguments;
      List<List<Integer>> locationIds = chopIntoParts((List<Integer>) arguments.get(0), 900);
      int affected = 0;
      for (List<Integer> chunk: locationIds) {
        affected += LocationDatabase.getLocationDatabase(mContext)
                .locationDao()
                .markAsRead(chunk);
      }
      result.success(affected);
    } else if (call.method.equals("requestPermission")) {
      if (mActivity != null) {
        LocationManagerController.requestPermission(mActivity);
        result.success(true);
      } else {
        result.success(false);
      }
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onListen(Object o, EventChannel.EventSink eventSink) {
    this.eventSink = eventSink;
      LocationManagerController.isLocationTrackingActive()
              .observeForever(this.stateObserver);
  }

  @Override
  public void onCancel(Object o) {
    LocationManagerController.isLocationTrackingActive()
            .removeObserver(this.stateObserver);
    this.eventSink = null;
  }
}
