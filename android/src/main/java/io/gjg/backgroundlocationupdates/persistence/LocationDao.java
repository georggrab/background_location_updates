package io.gjg.backgroundlocationupdates.persistence;

import android.arch.persistence.room.Dao;
import android.arch.persistence.room.Delete;
import android.arch.persistence.room.Insert;
import android.arch.persistence.room.Query;

import java.util.List;

@Dao
public interface LocationDao {

    @Query("SELECT * FROM location")
    List<LocationEntity> getAll();

    @Query("SELECT * FROM location WHERE read_count = 0")
    List<LocationEntity> getUnread();

    @Query("SELECT COUNT(*) from location")
    int countLocationTraces();

    @Query("SELECT COUNT(*) from location where read_count = 0")
    int countLocationTracesUnread();

    @Query("UPDATE location SET read_count = read_count + 1 WHERE id in (:ids)")
    int markAsRead(List<Integer> ids);

    @Insert
    void insertAll(LocationEntity... entities);

    @Delete
    void delete(LocationEntity entity);
}
