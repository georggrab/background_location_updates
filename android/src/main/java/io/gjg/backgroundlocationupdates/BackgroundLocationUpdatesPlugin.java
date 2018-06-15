package io.gjg.backgroundlocationupdates;

import android.app.Activity;
import android.arch.lifecycle.Observer;
import android.content.Context;
import android.support.annotation.Nullable;

import java.util.ArrayList;
import java.util.List;

import androidx.work.WorkStatus;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** BackgroundLocationUpdatesPlugin */
public class BackgroundLocationUpdatesPlugin implements MethodCallHandler, EventChannel.StreamHandler {
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

  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("startTrackingLocation")) {
      ArrayList<?> arguments = (ArrayList<?>) call.arguments;
      Integer requestInterval = (Integer) arguments.get(1);
      LocationManagerController.stopLocationTracking();
      result.success(LocationManagerController.scheduleLocationTracking(requestInterval));
    } else if (call.method.equals("stopTrackingLocation")) {
      LocationManagerController.stopLocationTracking();
      result.success(null);
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
