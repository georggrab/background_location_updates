package io.gjg.backgroundlocationupdates.persistence;

import android.annotation.TargetApi;
import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

@TargetApi(3)
public class TraceRetriever extends AsyncTask<TraceRetriever.TraceRetrievalMode, Void, List<LocationEntity>> {
    public enum TraceRetrievalMode {
        RETRIEVE_ALL, RETRIEVE_UNREAD
    }

    private static final String TAG = TraceRetriever.class.getSimpleName();
    private MethodChannel.Result result;
    private WeakReference<Context> mContext;

    public TraceRetriever(MethodChannel.Result result, Context mContext) {
        this.result = result;
        this.mContext = new WeakReference<>(mContext);
    }


    @Override
    protected List<LocationEntity> doInBackground(TraceRetrievalMode... modes) {
        final Context context = mContext.get();
        if (context == null) {
            Log.w(TAG, "Context is lost, unable to retrieve Location.");
            return null;
        }
        if (modes[0].equals(TraceRetrievalMode.RETRIEVE_UNREAD)) {
            return LocationDatabase.getLocationDatabase(context)
                    .locationDao()
                    .getUnread();
        } else if (modes[0].equals(TraceRetrievalMode.RETRIEVE_ALL)) {
            return LocationDatabase.getLocationDatabase(context)
                    .locationDao()
                    .getAll();
        }
        return null;
    }

    @Override
    protected void onPostExecute(List<LocationEntity> traces) {
        List<Map<String, Object>> out = new ArrayList<>();
        for (LocationEntity locationEntity: traces) {
            out.add(locationEntity.toMap());
        }
        result.success(out);
        mContext.clear();
    }
}
