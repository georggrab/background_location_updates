// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AndroidSpecificLocationData _$AndroidSpecificLocationDataFromJson(
    Map<String, dynamic> json) {
  return new AndroidSpecificLocationData(
      courseAccuracy: (json['courseAccuracy'] as num)?.toDouble(),
      provider: json['provider'] as String,
      speedAccuracy: (json['speedAccuracy'] as num)?.toDouble());
}

abstract class _$AndroidSpecificLocationDataSerializerMixin {
  double get courseAccuracy;
  double get speedAccuracy;
  String get provider;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'courseAccuracy': courseAccuracy,
        'speedAccuracy': speedAccuracy,
        'provider': provider
      };
}

IOSSpecificLocationData _$IOSSpecificLocationDataFromJson(
    Map<String, dynamic> json) {
  return new IOSSpecificLocationData(logicalFloor: json['logicalFloor'] as int);
}

abstract class _$IOSSpecificLocationDataSerializerMixin {
  int get logicalFloor;
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'logicalFloor': logicalFloor};
}

LocationTrace _$LocationTraceFromJson(Map<String, dynamic> json) {
  return new LocationTrace(
      id: json['id'] as int,
      latitude: (json['latitude'] as num)?.toDouble(),
      longitude: (json['longitude'] as num)?.toDouble(),
      altitude: (json['altitude'] as num)?.toDouble(),
      speed: (json['speed'] as num)?.toDouble(),
      readCount: json['readCount'] as int,
      time: json['time'] as int,
      course: (json['course'] as num)?.toDouble(),
      androidSpecifics: json['androidSpecifics'] == null
          ? null
          : new AndroidSpecificLocationData.fromJson(
              json['androidSpecifics'] as Map<String, dynamic>),
      iosSpecifics: json['iosSpecifics'] == null
          ? null
          : new IOSSpecificLocationData.fromJson(
              json['iosSpecifics'] as Map<String, dynamic>),
      verticalAccuracy: (json['verticalAccuracy'] as num)?.toDouble(),
      accuracy: (json['accuracy'] as num)?.toDouble());
}

abstract class _$LocationTraceSerializerMixin {
  int get id;
  double get latitude;
  double get longitude;
  double get altitude;
  double get speed;
  int get readCount;
  double get accuracy;
  double get verticalAccuracy;
  int get time;
  double get course;
  AndroidSpecificLocationData get androidSpecifics;
  IOSSpecificLocationData get iosSpecifics;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'latitude': latitude,
        'longitude': longitude,
        'altitude': altitude,
        'speed': speed,
        'readCount': readCount,
        'accuracy': accuracy,
        'verticalAccuracy': verticalAccuracy,
        'time': time,
        'course': course,
        'androidSpecifics': androidSpecifics,
        'iosSpecifics': iosSpecifics
      };
}
