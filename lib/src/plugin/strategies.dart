import 'dart:async';
import 'package:flutter/services.dart';

abstract class Strategy {
  Future<bool> invoke(MethodChannel channel);
  Future<void> revert(MethodChannel channel);
}

abstract class AndroidStrategy extends Strategy {}

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

abstract class IOSStrategy extends Strategy {
  static const int ACCURACY_BEST = 1;
  static const int ACCURACY_KILOMETER = 2;
  static const int ACCURACY_HUNDRED_METERS = 3;
  static const int ACCURACY_THREE_KILOMETERS = 4;
  static const int ACCURACY_NEAREST_TEN_METERS = 5;
}

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
