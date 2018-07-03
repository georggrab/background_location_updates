package io.gjg.backgroundlocationupdates.persistence;

import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;

import java.lang.ref.WeakReference;

public class TraceInserter extends AsyncTask<LocationEntity, Void, Void> {
    public enum TraceRetrievalMode {
        RETRIEVE_ALL, RETRIEVE_UNREAD
    }

    private static final String TAG = TraceRetriever.class.getSimpleName();
    private WeakReference<Context> mContext;

    public TraceInserter(Context mContext) {
        this.mContext = new WeakReference<>(mContext);
    }


    @Override
    protected Void doInBackground(LocationEntity... entities) {
        final Context context = mContext.get();
        if (context == null) {
            Log.w(TAG, "Context is lost, unable to retrieve Location.");
            return null;
        }
        LocationDatabase.getLocationDatabase(context).locationDao().insertAll(entities);
        return null;
    }
}
