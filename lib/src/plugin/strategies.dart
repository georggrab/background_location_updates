import 'dart:async';
import 'package:flutter/services.dart';

/// Abstract class representing a Strategy to retrieve
/// the User's location.
abstract class Strategy {
  /// Delegate the intent to execute the Strategy to the
  /// native Platform implementation
  Future<bool> invoke(MethodChannel channel);

  /// Delegate the intent to stop executing the strategy to the
  /// native Platform implementation
  Future<void> revert(MethodChannel channel);
}

/// Abstract class representing Android-Compatible Strategies
abstract class AndroidStrategy extends Strategy {}

/// Android Strategy delegating the intent to retrieve the location
/// based on a periodic background task to the native implementation.
class AndroidPeriodicRequestStrategy extends AndroidStrategy {
  Duration requestInterval;
  AndroidPeriodicRequestStrategy({this.requestInterval});

  @override
  Future<bool> invoke(MethodChannel channel) async {
    final bool success = await channel.invokeMethod(
        'trackStart/android-strategy:periodic',
        [this.requestInterval.inMilliseconds]);
    return success;
  }

  @override
  Future<void> revert(MethodChannel channel) async {
    await channel.invokeMethod('trackStop/android-strategy:periodic', []);
  }
}

/// Android Strategy delegating the intent to retrieve the location
/// based on a broadcast receiver to the native implementation
class AndroidBroadcastBasedRequestStrategy extends AndroidStrategy {
  Duration requestInterval;
  AndroidBroadcastBasedRequestStrategy({this.requestInterval});

  @override
  Future<bool> invoke(MethodChannel channel) async {
    final bool success = await channel.invokeMethod(
        'trackStart/android-strategy:broadcast',
        [this.requestInterval.inMilliseconds]);
    return success;
  }

  @override
  Future<void> revert(MethodChannel channel) async {
    await channel.invokeMethod('trackStop/android-strategy:broadcast', []);
  }
}

/// Abstract class representing iOS-Compatible Strategies
abstract class IOSStrategy extends Strategy {
  static const int ACCURACY_BEST = 1;
  static const int ACCURACY_KILOMETER = 2;
  static const int ACCURACY_HUNDRED_METERS = 3;
  static const int ACCURACY_THREE_KILOMETERS = 4;
  static const int ACCURACY_NEAREST_TEN_METERS = 5;
}

/// IOS Strategy delegating the intent to retrieve the location
/// based on the Significant Location Change API of CLLocationManager
class IOSSignificantLocationChangeStrategy extends IOSStrategy {
  int desiredAccuracy;

  IOSSignificantLocationChangeStrategy(
      {this.desiredAccuracy = IOSStrategy.ACCURACY_HUNDRED_METERS});
  @override
  Future<bool> invoke(MethodChannel channel) async {
    final bool success = await channel.invokeMethod(
        'trackStart/ios-strategy:significant-location-change',
        [desiredAccuracy]);
    return success;
  }

  @override
  Future<void> revert(MethodChannel channel) async {
    await channel
        .invokeMethod('trackStop/ios-strategy:significant-location-change', []);
  }
}

/// IOS Strategy delegating the intent to retrieve the location
/// based on the Location Change API of CLLocationManager. No Background
/// Updates will be retrieved using this Strategy, but it may be invoked while
/// the Application is running in order to retrieve a more accurate location reading.
class IOSLocationChangeStrategy extends IOSStrategy {
  int desiredAccuracy;

  IOSLocationChangeStrategy(
      {this.desiredAccuracy = IOSStrategy.ACCURACY_HUNDRED_METERS});

  @override
  Future<bool> invoke(MethodChannel channel) async {
    final bool success = await channel.invokeMethod(
        'trackStart/ios-strategy:location-change', [desiredAccuracy]);
    return success;
  }

  @override
  Future<void> revert(MethodChannel channel) async {
    await channel.invokeMethod('trackStop/ios-strategy:location-change', []);
  }
}
