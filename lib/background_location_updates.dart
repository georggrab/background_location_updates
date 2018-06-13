import 'dart:async';

import 'package:flutter/services.dart';

class BackgroundLocationUpdates {
  static const LOCATION_SINK_SQLITE = 0x001;
  static const MethodChannel _channel =
      const MethodChannel('plugins.gjg.io/background_location_updates');

  static const EventChannel _events =
      const EventChannel('plugins.gjg.io/background_location_updates/tracking_state');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

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

  static Future<List<dynamic>> getLatestBackgroundLocationUpdates() async {
    return _channel.invokeMethod('getLatestBackgroundLocationUpdates');
  }
}
