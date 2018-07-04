package io.gjg.backgroundlocationupdates.persistence;

import android.arch.persistence.room.ColumnInfo;
import android.arch.persistence.room.Entity;
import android.arch.persistence.room.PrimaryKey;
import android.location.Location;
import android.os.Build;

import java.util.HashMap;
import java.util.Map;

@Entity(tableName = "location")
public class LocationEntity {
    @PrimaryKey(autoGenerate = true)
    private Integer id;

    @ColumnInfo
    private Double accuracy;

    @ColumnInfo
    private Double longitude;

    @ColumnInfo
    private Double latitude;

    @ColumnInfo
    private Double altitude;

    @ColumnInfo
    private Double speed;

    @ColumnInfo
    private Long time;

    @ColumnInfo(name = "vertical_accuracy")
    private Double verticalAccuracy;

    @ColumnInfo
    private final Double course;

    @ColumnInfo(name = "course_accuracy")
    private Double courseAccuracy;

    @ColumnInfo(name = "speed_accuracy")
    private Double speedAccuracy;

    @ColumnInfo(name = "provider")
    private String provider;

    @ColumnInfo(name = "read_count")
    private Integer readCount;

    public LocationEntity(Double accuracy, Double verticalAccuracy, Double longitude, Double latitude, Double altitude, Double speed, Long time, Integer readCount, Double course, Double courseAccuracy, Double speedAccuracy, String provider) {
        this.accuracy = accuracy;
        this.longitude = longitude;
        this.latitude = latitude;
        this.altitude = altitude;
        this.time = time;
        this.readCount = readCount;
        this.courseAccuracy = courseAccuracy;
        this.speedAccuracy = speedAccuracy;
        this.provider = provider;
        this.verticalAccuracy = verticalAccuracy;
        this.speed = speed;
        this.course = course;
    }

    public static LocationEntity fromAndroidLocation(Location location) {
        Double vAcc = null, cAcc = null, speedAcc = null;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vAcc = (double) location.getVerticalAccuracyMeters();
            cAcc = (double) location.getBearingAccuracyDegrees();
            speedAcc = (double) location.getSpeedAccuracyMetersPerSecond();
        }

        return new LocationEntity(
                (double) location.getAccuracy(),
                vAcc,
                location.getLongitude(),
                location.getLatitude(),
                location.getAltitude(),
                (double )location.getSpeed(),
                location.getTime(),
                0,
                (double) location.getBearing(),
                cAcc,
                speedAcc,
                location.getProvider()
        );
    }

    public Map<String, Object> toMap() {
        final HashMap<String, Object> map = new HashMap<>();
        map.put("id", this.id.doubleValue());
        map.put("accuracy", this.accuracy);
        map.put("longitude", this.longitude);
        map.put("latitude", this.latitude);
        map.put("altitude", this.altitude);
        map.put("time", time.doubleValue());
        map.put("readCount", this.readCount != null? this.readCount.doubleValue(): 0.0);
        map.put("verticalAccuracy", this.verticalAccuracy);
        map.put("provider", this.provider != null? this.provider : "");
        map.put("course", this.course != null? this.course: 0.0);
        map.put("courseAccuracy", this.courseAccuracy != null? this.courseAccuracy: 0.0);
        map.put("speedAccuracy", this.speedAccuracy != null? this.speedAccuracy: 0.0);
        map.put("speed", this.speed != null? this.speed: 0.0);
        return map;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Double getAccuracy() {
        return accuracy;
    }

    public void setAccuracy(Double accuracy) {
        this.accuracy = accuracy;
    }

    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }

    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public Double getAltitude() {
        return altitude;
    }

    public void setAltitude(Double altitude) {
        this.altitude = altitude;
    }

    public Long getTime() {
        return time;
    }

    public void setTime(Long time) {
        this.time = time;
    }

    public Integer getReadCount() {
        return readCount;
    }

    public void setReadCount(Integer readCount) {
        this.readCount = readCount;
    }

    public Double getSpeed() {
        return speed;
    }

    public void setSpeed(Double speed) {
        this.speed = speed;
    }

    public Double getVerticalAccuracy() {
        return verticalAccuracy;
    }

    public void setVerticalAccuracy(Double verticalAccuracy) {
        this.verticalAccuracy = verticalAccuracy;
    }

    public Double getCourseAccuracy() {
        return courseAccuracy;
    }

    public void setCourseAccuracy(Double courseAccuracy) {
        this.courseAccuracy = courseAccuracy;
    }

    public Double getSpeedAccuracy() {
        return speedAccuracy;
    }

    public void setSpeedAccuracy(Double speedAccuracy) {
        this.speedAccuracy = speedAccuracy;
    }

    public String getProvider() {
        return provider;
    }

    public void setProvider(String provider) {
        this.provider = provider;
    }

    public Double getCourse() {
        return course;
    }
}
