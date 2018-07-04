package io.gjg.backgroundlocationupdates.persistence;

import android.arch.persistence.db.SupportSQLiteDatabase;
import android.arch.persistence.room.Database;
import android.arch.persistence.room.Room;
import android.arch.persistence.room.RoomDatabase;
import android.arch.persistence.room.migration.Migration;
import android.content.Context;
import android.support.annotation.NonNull;

@Database(entities = {LocationEntity.class}, version = 2)
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
                                    final String TABLE_TEMP = "_location_migration_1_2_temp";
                                    final String TABLE_ORIG = "location";

                                    final String CREATE_STMT_2 = "CREATE TABLE IF NOT EXISTS " +
                                            "`"+ TABLE_TEMP +"` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, " +
                                            "`accuracy` REAL, " +
                                            "`longitude` REAL, " +
                                            "`latitude` REAL, " +
                                            "`altitude` REAL," +
                                            " `speed` REAL, " +
                                            "`time` INTEGER, " +
                                            "`vertical_accuracy` REAL, " +
                                            "`course` REAL, " +
                                            "`course_accuracy` REAL, " +
                                            "`speed_accuracy` REAL, `provider` TEXT, `read_count` INTEGER)";

                                    database.execSQL(CREATE_STMT_2);

                                    database.execSQL("INSERT INTO `" + TABLE_TEMP + "` (" +
                                                "id, accuracy, longitude, latitude, altitude, time" +
                                            ") SELECT id, accuracy, longitude, latitude, altitude, time FROM " + TABLE_ORIG);

                                    database.execSQL("DROP TABLE " + TABLE_ORIG);
                                    database.execSQL("ALTER TABLE " + TABLE_TEMP + " RENAME TO " + TABLE_ORIG);
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
