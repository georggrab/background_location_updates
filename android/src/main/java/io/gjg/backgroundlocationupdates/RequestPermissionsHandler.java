package io.gjg.backgroundlocationupdates;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.support.v4.content.ContextCompat;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.PluginRegistry;

public class RequestPermissionsHandler implements PluginRegistry.RequestPermissionsResultListener, EventChannel.StreamHandler {
    public static final int PERMISSION_REQUEST_FINE_LOCATION = 0x0424242;
    private final Context mContext;
    private RequestPermissionsHandler.PermissionResult result;
    private EventChannel.EventSink sink;

    public RequestPermissionsHandler(Context context) {
        this.mContext = context;
    }

    @Override
    public boolean onRequestPermissionsResult(int i, String[] strings, int[] ints) {
        if (i == PERMISSION_REQUEST_FINE_LOCATION) {
            result = PermissionResult.GRANTED;
        } else {
            result = PermissionResult.DENIED;
        }
        this.sink.success(this.result.result);
        return true;
    }

    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
        this.sink = eventSink;
        if (this.result == null) {
            if (RequestPermissionsHandler.hasPermission(this.mContext)) {
                this.result = PermissionResult.GRANTED;
            } else {
                this.result = PermissionResult.DENIED;
            }
        }
        this.sink.success(this.result.result);
    }

    @Override
    public void onCancel(Object o) {

    }

    public static boolean hasPermission(Context context) {
        return (ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED ||
                ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED);
    }

    public enum PermissionResult {
        GRANTED(1),
        PARTIAL(2),
        DENIED(3);

        public int result;
        PermissionResult(int result) {
            this.result = result;
        }
    }
}
