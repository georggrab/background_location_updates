import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';

import 'package:background_location_updates/src/plugin/strategies.dart';
import 'package:background_location_updates/src/model/location_data.dart';
import 'package:background_location_updates/src/model/permission_state.dart';

/**
 * Retrieve periodic location updates, even when the main App is not running. 
 * Useful for Navigation Apps to keep a rough idea of where the User is heading, and various other purposes. 
 * Please don't be evil though, and tell the User exactly how, when and why you wish to retrieve her location. 
 * Before integrating this Plugin in your app, please read [this](https://www.dataprotection.ie/docs/Guidance-Note-for-Data-Controllers-on-Location-Data/1587.htm).
 */
class BackgroundLocationUpdates {
  static Strategy _lastStrategy;
  static const MethodChannel _channel =
      const MethodChannel('plugins.gjg.io/background_location_updates');

  static const EventChannel _trackingStateChangeEvents = const EventChannel(
      'plugins.gjg.io/background_location_updates/tracking_state');

  static const EventChannel _permissionStateChangeEvents = const EventChannel(
      'plugins.gjg.io/background_location_updates/permission_state');

  /// Starts the Location Tracking using the specified strategies.
  static Future<void> startTrackingLocation(
      {AndroidStrategy androidStrategy, IOSStrategy iOSStrategy}) async {
    if (Platform.isAndroid) {
      BackgroundLocationUpdates._lastStrategy = androidStrategy;
      await androidStrategy.invoke(_channel);
    } else if (Platform.isIOS) {
      BackgroundLocationUpdates._lastStrategy = iOSStrategy;
      await iOSStrategy.invoke(_channel);
    }
  }

  /// Returns a [Stream] of [bool] indicating whether the Location Tracking is active.
  static Stream<bool> streamLocationActive() {
    return _trackingStateChangeEvents.receiveBroadcastStream().cast<bool>();
  }

  /// Stops the Location Tracking.
  static Future<bool> stopTrackingLocation() async {
    if (BackgroundLocationUpdates._lastStrategy == null) {
      await _channel.invokeMethod('revertActiveStrategy', []);
      return true;
    } else {
      await BackgroundLocationUpdates._lastStrategy.revert(_channel);
      return true;
    }
  }

  /// Tries requesting the permission for tracking the User in the Background.
  ///
  ///  Returns a [PermissionState] indicating
  /// if a dialogBox requesting the permission has been shown to the User.
  static Future<PermissionState> requestPermission() async {
    if (await getPermissionState().first == PermissionState.GRANTED) {
      return PermissionState.GRANTED;
    }
    await _channel.invokeMethod('requestPermission');
    return getPermissionState().take(2).last;
  }

  /// Gets a Stream representing the Permission State of the Background Tracking.
  ///
  /// Returns a [Stream] of [PermissionState]s, indicating Permission State changes as they occur.
  static Stream<PermissionState> getPermissionState() {
    return _permissionStateChangeEvents
        .receiveBroadcastStream()
        .cast<int>()
        .map(toPermissionState);
  }

  /// Gets all Location Traces, regardless if they have been marked as read or not.
  ///
  /// Returns a Future of [List<LocationTrace>]
  static Future<List<LocationTrace>> getLocationTraces() async {
    List<dynamic> traces = await _channel.invokeMethod('getLocationTraces');
    return traces
        .cast<Map<dynamic, dynamic>>()
        .map((trace) => trace.cast<String, dynamic>())
        .map(LocationTrace.fromMap)
        .toList();
  }

  /// Gets only the Location Traces that have not been marked as read previously
  ///
  /// Returns a Future of [List<LocationTrace>]
  static Future<List<LocationTrace>> getUnreadLocationTraces() async {
    List<dynamic> traces =
        await _channel.invokeMethod('getUnreadLocationTraces');
    return traces
        .cast<Map>()
        .map((trace) => trace.cast<String, dynamic>())
        .map(LocationTrace.fromMap)
        .toList();
  }

  /// Gets the internal SQLite Database Path. Can be used in conjunction with other extensions
  /// such as SQFlite.
  ///
  /// Returns a [Future<String>], denoting the absolute path of the SQLite Database.
  static Future<String> getSqliteDatabasePath() async {
    final String path = await _channel.invokeMethod('getSqliteDatabasePath');
    return path;
  }

  /// Gets the count of Unread Location Traces.
  ///
  /// Returns a [Future<int>].
  static Future<int> getUnreadLocationTracesCount() async {
    final int count =
        await _channel.invokeMethod('getUnreadLocationTracesCount');
    return count;
  }

  /// Gets the count of all Location Traces.
  ///
  /// Returns a [Future<int>].
  static Future<int> getLocationTracesCount() async {
    final int count = await _channel.invokeMethod('getLocationTracesCount');
    return count;
  }

  /// Marks a list of [ids] as read. The [ids] may be retrieved from a List of [LocationTrace]
  /// like this:
  ///
  /// ```dart
  /// await BackgroundLocationUpdates.markAsRead(
  ///     traces.map((trace) => trace.id).asList()
  /// );
  /// ```
  ///
  /// Returns a [Future<void>], indicating when the operation is complete.
  static Future<void> markAsRead(List<int> ids) async {
    await _channel.invokeMethod('markAsRead', [ids]);
  }
}
