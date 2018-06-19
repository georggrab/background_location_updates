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

class BackgroundLocationUpdates {
  static const LOCATION_SINK_SQLITE = 0x001;
  static const MethodChannel _channel =
      const MethodChannel('plugins.gjg.io/background_location_updates');

  static const EventChannel _events =
      const EventChannel('plugins.gjg.io/background_location_updates/tracking_state');

  static Future<bool> startTrackingLocation(int sink, {Duration requestInterval}) async {
    final bool success = await _channel.invokeMethod('startTrackingLocation', [sink, requestInterval.inMilliseconds]);
    return success;
  }

  static Stream<bool> streamLocationActive() {
    return _events.receiveBroadcastStream().cast<bool>();
  }

  static Future<void> stopTrackingLocation() async {
    return _channel.invokeMethod('stopTrackingLocation');
  }

  static Future<void> requestPermission() async {
    return _channel.invokeMethod('requestPermission');
  }

  static Future<List<Map<String, double>>> getLocationTraces() async {
    List<dynamic> traces = await _channel.invokeMethod('getLocationTraces');
    return traces.cast<Map<dynamic, dynamic>>().map((trace) => trace.cast<String, double>()).toList();
  }

  static Future<List<Map<String, double>>> getUnreadLocationTraces() async {
    List<dynamic> traces = await _channel.invokeMethod('getUnreadLocationTraces');
    return traces.cast<Map>().map((trace) => trace.cast<String, double>()).toList();
  }

  static Future<int> getUnreadLocationTracesCount() async {
    final int count = await _channel.invokeMethod('getUnreadLocationTracesCount');
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
