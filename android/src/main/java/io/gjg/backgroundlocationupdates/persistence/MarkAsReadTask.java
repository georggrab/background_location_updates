package io.gjg.backgroundlocationupdates.persistence;

import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

public class MarkAsReadTask extends AsyncTask<Integer, Void, Void> {
    private static final String TAG = MarkAsReadTask.class.getSimpleName();
    private WeakReference<Context> mContext;

    public MarkAsReadTask(Context mContext) {
        this.mContext = new WeakReference<>(mContext);
    }


    @Override
    protected Void doInBackground(Integer... ids) {
        final Context context = mContext.get();
        if (context == null) {
            Log.w(TAG, "Context is lost, unable to retrieve Location.");
            return null;
        }
        LocationDatabase.getLocationDatabase(context)
                .locationDao().markAsRead(Arrays.asList(ids));
        return null;
    }
}
