import 'dart:io' show Platform;

import 'package:json_annotation/json_annotation.dart';
part 'location_data.g.dart';

@JsonSerializable()
class AndroidSpecificLocationData extends Object
    with _$AndroidSpecificLocationDataSerializerMixin {
  /// The Course Accuracy, measured in degrees
  /// In the Android Documentation, this is referred to as
  /// bearingAccuracy.
  double courseAccuracy;

  /// The Speed Accuracy, measured in m/s.
  double speedAccuracy;

  /// The Provider of this Location Trace
  String provider;

  AndroidSpecificLocationData(
      {this.courseAccuracy, this.provider, this.speedAccuracy});

  @override
  String toString() {
    return 'AndroidSpecific(cAcc=$courseAccuracy, provider=$provider, sAcc=$speedAccuracy)';
  }

  factory AndroidSpecificLocationData.fromJson(Map<String, dynamic> json) =>
      _$AndroidSpecificLocationDataFromJson(json);
}

@JsonSerializable()
class IOSSpecificLocationData extends Object
    with _$IOSSpecificLocationDataSerializerMixin {
  /// The Logical Floor of the User. See iOS Documentation.
  /// May be null.
  int logicalFloor;

  IOSSpecificLocationData({this.logicalFloor});

  @override
  String toString() {
    return 'IOSSpecific(floor=$logicalFloor)';
  }

  factory IOSSpecificLocationData.fromJson(Map<String, dynamic> json) =>
      _$IOSSpecificLocationDataFromJson(json);
}

@JsonSerializable()
class LocationTrace extends Object with _$LocationTraceSerializerMixin {
  /// The unique, monotonically increasing ID of this Trace.
  int id;

  /// The Latitude of the Device
  double latitude;

  /// The Longitude of the Device
  double longitude;

  /// The Altitude. Only available when the Location Source is GPS.
  double altitude;

  /// The current Device Speed
  double speed;

  /// How many times this trace has been read from the SQLite Database
  int readCount;

  /// The horizontal accuracy radius of this Trace, in meters.
  double accuracy;

  /// The vertical accuracy radius of this Trace, in meters.
  double verticalAccuracy;

  /// The Unix Epoch, in Milliseconds.
  int time;

  /// Where the device is currently heading, measured in degrees from north
  double course;

  /// The Android specific Location Data. `null` if on a iOS Device.
  AndroidSpecificLocationData androidSpecifics;

  /// The iOS specific Location Data. `null` if on an Android Device.
  IOSSpecificLocationData iosSpecifics;

  LocationTrace(
      {this.id,
      this.latitude,
      this.longitude,
      this.altitude,
      this.speed,
      this.readCount,
      this.time,
      this.course,
      this.androidSpecifics,
      this.iosSpecifics,
      this.verticalAccuracy,
      this.accuracy});

  static LocationTrace fromMap(Map<String, dynamic> map) {
    try {
      IOSSpecificLocationData iosSpecificLocationData;
      AndroidSpecificLocationData androidSpecificLocationData;

      if (Platform.isAndroid) {
        androidSpecificLocationData = AndroidSpecificLocationData(
            courseAccuracy: map["courseAccuracy"] as double,
            speedAccuracy: map["speedAccuracy"] as double,
            provider: map["provider"] as String);
      } else if (Platform.isIOS) {
        iosSpecificLocationData = IOSSpecificLocationData(logicalFloor: null);
      }
      final trace = LocationTrace(
        id: map["id"].toInt(),
        latitude: map["latitude"] as double,
        longitude: map["longitude"] as double,
        time: (map["time"] as double).toInt(),
        speed: (map["speed"] as double),
        readCount: (map["readCount"] as double).toInt(),
        accuracy: map["accuracy"] as double,
        verticalAccuracy: map["verticalAccuracy"] as double,
        course: map["course"] as double,
        androidSpecifics: androidSpecificLocationData,
        iosSpecifics: iosSpecificLocationData,
      );
      if (map["altitude"] as double != 0.0) {
        trace.altitude = map["altitude"] as double;
      }
      return trace;
    } catch (err) {
      throw err;
    }
  }

  @override
  String toString() {
    return "LocationTrace(id=$id, lat=$latitude, lng=$longitude, acc=$accuracy, vAcc=$verticalAccuracy, speed=$speed, alt=$altitude, readCount=$readCount, time=$time, course=$course, ios=$iosSpecifics, android=$androidSpecifics)";
  }

  factory LocationTrace.fromJson(Map<String, dynamic> json) =>
      _$LocationTraceFromJson(json);
}
