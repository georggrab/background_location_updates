package io.gjg.backgroundlocationupdates.persistence;

import android.arch.persistence.db.SupportSQLiteDatabase;
import android.arch.persistence.room.Database;
import android.arch.persistence.room.Room;
import android.arch.persistence.room.RoomDatabase;
import android.arch.persistence.room.migration.Migration;
import android.content.Context;
import android.support.annotation.NonNull;

@Database(entities = {LocationEntity.class}, version = 2, exportSchema = false)
public abstract class LocationDatabase extends RoomDatabase {

    private static LocationDatabase INSTANCE;

    public abstract LocationDao locationDao();

    public static LocationDatabase getLocationDatabase(Context context) {
        if (INSTANCE == null) {
            INSTANCE =
                    Room.databaseBuilder(context.getApplicationContext(), LocationDatabase.class, "locations")
                            .addMigrations(new Migration(1, 2) {
                                @Override
                                public void migrate(@NonNull SupportSQLiteDatabase database) {
                                    database.execSQL("ALTER TABLE location" +
                                            " ADD COLUMN speed REAL");
                                    database.execSQL("ALTER TABLE location" +
                                            " ADD COLUMN vertical_accuracy REAL");
                                    database.execSQL("ALTER TABLE location" +
                                            " ADD COLUMN course REAL");
                                    database.execSQL("ALTER TABLE location" +
                                            " ADD COLUMN course_accuracy REAL");
                                    database.execSQL("ALTER TABLE location" +
                                            " ADD COLUMN speed_accuracy REAL");
                                    database.execSQL("ALTER TABLE location" +
                                            " ADD COLUMN provider TEXT");
                                }
                            })
                            .build();
        }
        return INSTANCE;
    }

    public static void destroyInstance() {
        INSTANCE = null;
    }
}
