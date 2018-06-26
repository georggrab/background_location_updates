// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background_location_updates.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationTrace _$LocationTraceFromJson(Map<String, dynamic> json) {
  return new LocationTrace(
      id: json['id'] as int,
      latitude: (json['latitude'] as num)?.toDouble(),
      longitude: (json['longitude'] as num)?.toDouble(),
      altitude: (json['altitude'] as num)?.toDouble(),
      readCount: json['readCount'] as int,
      accuracy: (json['accuracy'] as num)?.toDouble());
}

abstract class _$LocationTraceSerializerMixin {
  int get id;
  double get latitude;
  double get longitude;
  double get altitude;
  int get readCount;
  double get accuracy;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'latitude': latitude,
        'longitude': longitude,
        'altitude': altitude,
        'readCount': readCount,
        'accuracy': accuracy
      };
}
