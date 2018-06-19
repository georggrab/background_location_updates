/*
 *  Copyright 2018 Georg Grab
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
*/

import 'dart:async';
import 'package:flutter/services.dart';

enum PermissionState { GRANTED, PARTIAL, DENIED }

PermissionState toPermissionState(int nativeCode) {
  switch (nativeCode) {
    case 1:
      return PermissionState.GRANTED;
    case 2:
      return PermissionState.PARTIAL;
    case 3:
      return PermissionState.DENIED;
    default:
      throw 'Constructed invalid permissionState from native code: $nativeCode';
  }
}

class LocationTrace {
  int id;
  double latitude;
  double longitude;
  double altitude;
  int readCount;
  double accuracy;

  LocationTrace({this.id, this.latitude, this.longitude, this.altitude, this.readCount, this.accuracy});

  static LocationTrace fromMap(Map<String, double> map) {
    final trace = LocationTrace(
      id: map["id"].toInt(),
      latitude: map["latitude"],
      longitude: map["longitude"],
      readCount: map["readCount"].toInt(),
      accuracy: map["accuracy"]
    );
    if (map["altitude"] != 0.0) {
      trace.altitude = map["altitude"];
    }
    return trace;
  }

  @override
    String toString() {
      return "LocationTrace(id=$id, lat=$latitude, lng=$longitude, acc=$accuracy, alt=$altitude, readCount=$readCount)";
    }
}

class BackgroundLocationUpdates {
  static const LOCATION_SINK_SQLITE = 0x001;
  static const MethodChannel _channel =
      const MethodChannel('plugins.gjg.io/background_location_updates');

  static const EventChannel _trackingStateChangeEvents = const EventChannel(
      'plugins.gjg.io/background_location_updates/tracking_state');

  static const EventChannel _permissionStateChangeEvents = const EventChannel(
      'plugins.gjg.io/background_location_updates/permission_state');

  static Future<bool> startTrackingLocation(int sink,
      {Duration requestInterval}) async {
    final bool success = await _channel.invokeMethod(
        'startTrackingLocation', [sink, requestInterval.inMilliseconds]);
    return success;
  }

  static Stream<bool> streamLocationActive() {
    return _trackingStateChangeEvents.receiveBroadcastStream().cast<bool>();
  }

  static Future<void> stopTrackingLocation() async {
    return _channel.invokeMethod('stopTrackingLocation');
  }

  /// Try requesting the permission for tracking the User in the Background Returns a [bool] indicating
  /// if a dialogBox requesting the permission has been shown to the User.
  static Future<bool> requestPermission() async {
    final bool permissionDialogShown =
        await _channel.invokeMethod('requestPermission');
    return permissionDialogShown;
  }

  /// Get a Stream representing the Permission State of the Background Tracking
  static Stream<PermissionState> getPermissionState() {
    return _permissionStateChangeEvents
        .receiveBroadcastStream()
        .cast<int>()
        .map(toPermissionState);
  }

  static Future<List<LocationTrace>> getLocationTraces() async {
    List<dynamic> traces = await _channel.invokeMethod('getLocationTraces');
    return traces
        .cast<Map<dynamic, dynamic>>()
        .map((trace) => trace.cast<String, double>())
        .map(LocationTrace.fromMap)
        .toList();
  }

  static Future<List<LocationTrace>> getUnreadLocationTraces() async {
    List<dynamic> traces =
        await _channel.invokeMethod('getUnreadLocationTraces');
    return traces
        .cast<Map>()
        .map((trace) => trace.cast<String, double>())
        .map(LocationTrace.fromMap)
        .toList();
  }

  static Future<int> getUnreadLocationTracesCount() async {
    final int count =
        await _channel.invokeMethod('getUnreadLocationTracesCount');
    return count;
  }

  static Future<int> getLocationTracesCount() async {
    final int count = await _channel.invokeMethod('getUnreadLocationCount');
    return count;
  }

  static Future<void> markAsRead(List<int> ids) async {
    await _channel.invokeMethod('markAsRead', [ids]);
  }
}
