package io.gjg.backgroundlocationupdates.persistence;

import android.arch.persistence.room.ColumnInfo;
import android.arch.persistence.room.Entity;
import android.arch.persistence.room.PrimaryKey;

import java.util.HashMap;
import java.util.Map;

@Entity(tableName = "location")
public class LocationEntity {
    @PrimaryKey(autoGenerate = true)
    private int id;

    @ColumnInfo
    private double accuracy;

    @ColumnInfo
    private double longitude;

    @ColumnInfo
    private double latitude;

    @ColumnInfo
    private double altitude;

    @ColumnInfo
    private long time;

    @ColumnInfo(name = "read_count")
    private int readCount;

    public LocationEntity(double accuracy, double longitude, double latitude, double altitude, long time, int readCount) {
        this.accuracy = accuracy;
        this.longitude = longitude;
        this.latitude = latitude;
        this.altitude = altitude;
        this.time = time;
        this.readCount = readCount;
    }

    public Map<String, Double> toMap() {
        final HashMap<String, Double> map = new HashMap<>();
        map.put("id", Integer.valueOf(this.id).doubleValue());
        map.put("accuracy", this.accuracy);
        map.put("longitude", this.longitude);
        map.put("latitude", this.latitude);
        map.put("altitude", this.altitude);
        map.put("time", Long.valueOf(time).doubleValue());
        map.put("readCount", Integer.valueOf(this.readCount).doubleValue());
        return map;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public double getAccuracy() {
        return accuracy;
    }

    public void setAccuracy(double accuracy) {
        this.accuracy = accuracy;
    }

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    public double getAltitude() {
        return altitude;
    }

    public void setAltitude(double altitude) {
        this.altitude = altitude;
    }

    public long getTime() {
        return time;
    }

    public void setTime(long time) {
        this.time = time;
    }

    public int getReadCount() {
        return readCount;
    }

    public void setReadCount(int readCount) {
        this.readCount = readCount;
    }
}
