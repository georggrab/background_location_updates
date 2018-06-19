package io.gjg.backgroundlocationupdates.persistence;

import android.arch.persistence.room.Database;
import android.arch.persistence.room.Room;
import android.arch.persistence.room.RoomDatabase;
import android.content.Context;

@Database(entities = {LocationEntity.class}, version = 1, exportSchema = false)
public abstract class LocationDatabase extends RoomDatabase {

    private static LocationDatabase INSTANCE;

    public abstract LocationDao locationDao();

    public static LocationDatabase getLocationDatabase(Context context) {
        if (INSTANCE == null) {
            INSTANCE =
                    Room.databaseBuilder(context.getApplicationContext(), LocationDatabase.class, "locations")
                            // allow queries on the main thread.
                            // Don't do this on a real app! See PersistenceBasicSample for an example.
                            .allowMainThreadQueries()
                            .build();
        }
        return INSTANCE;
    }

    public static void destroyInstance() {
        INSTANCE = null;
    }
}
