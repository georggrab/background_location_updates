package io.gjg.backgroundlocationupdates.persistence;

import android.annotation.TargetApi;
import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;

import java.lang.ref.WeakReference;

import io.flutter.plugin.common.MethodChannel;

@TargetApi(3)
public class CountRetriever extends AsyncTask<CountRetriever.CountRetrievalMode, Void, Integer> {
    public enum CountRetrievalMode {
        RETRIEVE_ALL, RETRIEVE_UNREAD
    }

    private static final String TAG = CountRetriever.class.getSimpleName();
    private MethodChannel.Result result;
    private WeakReference<Context> mContext;

    public CountRetriever(MethodChannel.Result result, Context mContext) {
        this.result = result;
        this.mContext = new WeakReference<>(mContext);
    }


    @Override
    protected Integer doInBackground(CountRetrievalMode... modes) {
        final Context context = mContext.get();
        if (context == null) {
            Log.w(TAG, "Context is lost, unable to retrieve Location.");
            return null;
        }
        if (modes[0].equals(CountRetrievalMode.RETRIEVE_UNREAD)) {
            return LocationDatabase.getLocationDatabase(context)
                    .locationDao()
                    .countLocationTracesUnread();
        } else if (modes[0].equals(CountRetrievalMode.RETRIEVE_ALL)) {
            return LocationDatabase.getLocationDatabase(context)
                    .locationDao()
                    .countLocationTraces();
        }
        return null;
    }

    @Override
    protected void onPostExecute(Integer traces) {
        mContext.clear();
        result.success(traces);
    }
}
