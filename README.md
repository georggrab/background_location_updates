# background_location_updates

*This plugin is currently unmaintained. Do not use it. If you are interested in continuing to maintain this plugin, please contact me directly.*

Retrieve periodic location updates, even when the main App is not running. Useful for Navigation Apps to keep a rough idea of where the User is heading, and various other purposes. Please don't be evil though, and tell the User exactly how, when and why you wish to retrieve her location.
Before integrating this Plugin in your app, please read [this](https://www.dataprotection.ie/docs/Guidance-Note-for-Data-Controllers-on-Location-Data/1587.htm).

*This Plugin is heavily WIP, shouldn't be used in Production yet, and the API is likely to change by the hour.*

## Table of Contents

<!-- toc -->

- [Getting Started](#getting-started)
  * [Get the Package](#get-the-package)
  * [Android Permissions](#android-permissions)
  * [iOS Specifics](#ios-specifics)
    + [Podfile & Swift Language Version](#podfile--swift-language-version)
    + [iOS Permissions](#ios-permissions)
- [Documentation](#documentation)
  * [Importing the Package](#importing-the-package)
  * [Requesting Permissions](#requesting-permissions)
  * [Get Permission State](#get-permission-state)
  * [Location Tracking](#location-tracking)
    + [Android Strategies](#android-strategies)
      - [AndroidBroadcastBasedRequestStrategy](#androidbroadcastbasedrequeststrategy)
      - [AndroidPeriodicRequestStrategy](#androidperiodicrequeststrategy)
    + [IOS Strategies](#ios-strategies)
      - [SignificantLocationChangeStrategy](#significantlocationchangestrategy)
      - [LocationChangeStrategy](#locationchangestrategy)
  * [Stopping Location Tracking](#stopping-location-tracking)
  * [Getting all unread Location Traces](#getting-all-unread-location-traces)
  * [Number of Traces](#number-of-traces)
  * [Keep informed about the State of the Plugin](#keep-informed-about-the-state-of-the-plugin)
  * [Getting the internal Sqlite DB Path](#getting-the-internal-sqlite-db-path)
  * [Getting all Location Traces](#getting-all-location-traces)
- [FAQ](#faq)
  * [I'm getting a SecurityException on Android when a new location is arriving](#im-getting-a-securityexception-on-android-when-a-new-location-is-arriving)
  * [The whole App is crashing on iOS when starting Location Tracking](#the-whole-app-is-crashing-on-ios-when-starting-location-tracking)
  * [The App works on iOS, but nothing is happening](#the-app-works-on-ios-but-nothing-is-happening)

<!-- tocstop -->

## Getting Started

### Get the Package & Documentation

Add the following to your `pubspec.yml`:

```yaml
dependencies:
  background_location_updates: ^1.0.3
```

Verify the latest verision on [pub](https://pub.dartlang.org/packages/background_location_updates). Consult the Dartdoc of this Plugin [here](https://pub.dartlang.org/documentation/background_location_updates/latest/).

**Warning: The internal SQLite schema changed from 0.3.6 to 1.0.0.** This may be a breaking change.

### Android Permissions

In your `src/main/app/AndroidManifest.xml`, we'll need to register the appropriate permission. **Based on the Android Location Strategy you intend on using, you'll need to put some additional things in your Manifest. See below.**

```xml
<manifest ...>
    ....
    <!-- Alternatively: ACCESS_COARSE_LOCATION -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
</manifest>
```

### iOS Specifics

#### Podfile & Swift Language Version

**You don't have to do this if you created your project with `flutter create ... -i swift`.**
This Plugin will only work with the Swift Podfile (get it from [here](https://github.com/flutter/flutter/blob/master/packages/flutter_tools/templates/cocoapods/Podfile-swift), replace `ios/Podfile`, delete `ios/Podfile.lock`). Afterwards you'll need to set the Swift Language Version to the latest one in the XCode Project if you haven't already. See [here](https://stackoverflow.com/questions/47743271/the-swift-language-version-swift-version-build-setting-error-with-project-in) for instructions.


#### iOS Permissions
We'll first have to tell iOS that the app wishes to be started on location updates. Then, we have to justify to the User why we're intending to use their location. Both of these things are taken care of by setting the appropriate keys in `ios/Runner/Info.plist`:

```xml
<!-- We want to receive location updates in background -->
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
</array>
....

<!-- This key is for iOS 10 and earlier -->
<key>NSLocationAlwaysUsageDescription</key>
<string>Selling it on the black market</string>

<!-- This key is for iOS 11+. Justify here why you need Background Location. -->
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Selling it on the black market</string>
<!-- This key is for iOS 11+. Justify here why you 
need basic Location Services (while the App is running). -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Selling it on the black market</string>
```

## Documentation
### Importing the Package

```dart
import 'package:background_location_updates/background_location_updates.dart';
```

### Requesting Permissions
```dart
PermissionState granted = await BackgroundLocationUpdates.requestPermission()
```
On both Android and iOS, this will show a Permission Request Alertbox to the User. After the User has consented, further calls to this method will have no effect, and the other API Methods described below will work as intended.

### Get Permission State

```dart
BackgroundLocationUpdates.getPermissionState().listen((PermissionState state) {
    ...
});
// alternatively
PermissionState current = await BackgroundLocationUpdates.getPermissionState().first;
```

The PermissionState can take on the following values:

```dart
// Everything is fine, the User
// has granted Always on Permission
PermissionState.GRANTED

// You will only receive this on iOS 11+:
// The User has only granted your app to use
// location services when it is in use
PermissionState.PARTIAL

// The User denied your request
PermissionState.DENIED
```

The only way to change a `Partial` or `Denied` PermissionState is through the Phone Settings. You should however respect the decision the User has made and implement reacting to these Permission States appropriately.

### Location Tracking

After you've asked the User for appropriate permissions, start the Location Tracking.

```dart
await BackgroundLocationUpdates.startTrackingLocation(
       iOSStrategy: IOSSignificantLocationChangeStrategy(),
       androidStrategy: AndroidBroadcastBasedRequestStrategy(requestInterval:  const Duration(seconds: 30)));
```
For each Platform, we have a multitude of possibilities available to actually receive the Location. Some of them are available through this Plugin. You specify what strategy you want to use by setting the `iOSStrategy` and `androidStrategy` parameters.

#### Android Strategies

##### AndroidBroadcastBasedRequestStrategy

```dart
AndroidBroadcastBasedRequestStrategy(
    requestInterval: const Duration(seconds: 30)));
```

The `AndroidBroadcastBasedRequestStrategy` provides the Location at the discretion of the Android OS. How often the Location is actually received depends on several factors, such as Battery Life, Android OS Version (starting from Android Oreo, you will only receive the Background Location about 3x an hour regardless of what you put in `requestInterval`, see [here](https://developer.android.com/about/versions/oreo/background-location-limits) for more info), and whether the App is in the Foreground or Background. If the App is in the Foreground, the `requestInterval` is usually respected by all Android Versions.
This strategy uses the `FusedLocationProviderClient.requestLocationUpdates` ([see here](https://developers.google.com/android/reference/com/google/android/gms/location/FusedLocationProviderClient.html#requestLocationUpdates)) infrastructure to request the Location. The Location will received through the following Broadcast, which you must register in your Manifest:

```xml
<manifest ...>
    ...
    <application ...>
        ...
        <receiver android:name="io.gjg.backgroundlocationupdates.locationstrategies.broadcast.LocationUpdatesBroadcastReceiver">
           <intent-filter>
               <action android:name="io.gjg.backgroundlocationupdates.ACTION_PROCESS_LOCATION_UPDATE" />
           </intent-filter>
        </receiver>
    </application>
</manifest>
```

If you want to make the location tracking survive after Reboot, put this in your manifest additionally:

```xml
<manifest ...>
    ...
    <!-- Permission to receive the BOOT_COMPLETED Broadcast -->
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <application ...>
        ...
        <!-- A BroadcastReceiver for kicking off the Tracking again after reboot -->
        <receiver android:name="io.gjg.backgroundlocationupdates.locationstrategies.broadcast.BroadcastBasedBootBroadcastReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
            </intent-filter>
        </receiver>
    </application>
</manifest>
```

##### AndroidPeriodicRequestStrategy

```dart
AndroidPeriodicRequestStrategy(
    requestInterval: const Duration(minutes: 30)));
```

This strategy will work based on a Periodic Background Task, that will be executed every `requestInterval` seconds. This means the App is requesting the Location at its own discretion. You will get a Location Update every `requestInterval` seconds, even on Android Oreo and above. However, on Android Oreo and above, the Location Update will only change in value about 3x an hour (see [here](https://developer.android.com/about/versions/oreo/background-location-limits) for more information on this). On lower Android Versions, you will probably receive an updated Location much more often through this method. Keep in mind however that requesting the Location is harmful on Battery Life, so please be careful with this strategy, unless you want your users to uninstall your App very quickly.

If you want to make the Strategy survive after Reboot, put this in your manifest additionally:

```xml
<manifest ...>
    ...
    <!-- Permission to receive the BOOT_COMPLETED Broadcast -->
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <application ...>
        ...
        <!-- A BroadcastReceiver for kicking off the Tracking again after reboot -->
        <!-- Hint, this is a different receiver than the one above!! -->
        <receiver android:name="io.gjg.backgroundlocationupdates.locationstrategies.periodic.PeriodicBootBroadcastReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
            </intent-filter>
        </receiver>
    </application>
</manifest>
```

#### IOS Strategies

##### SignificantLocationChangeStrategy
```dart
IOSSignificantLocationChangeStrategy(
    desiredAccuracy: IOSStrategy.ACCURACY_HUNDRED_METERS
);
```
You will receive new Locations once it changes by a significant amount, which means about [500 meters or more for Apple](https://developer.apple.com/documentation/corelocation/getting_the_user_s_location/using_the_significant_change_location_service). If the App is in foreground, you can further explain the desired accuracy through `desiredAccuracy`.
There is no way to make this persistent across Device Reboots.

##### LocationChangeStrategy
```dart
IOSLocationChangeStrategy(
    desiredAccuracy: IOSStrategy.ACCURACY_HUNDRED_METERS
);
```
You will receive new Locations based on the `desiredAccuracy` that you specified.

### Stopping Location Tracking

```dart
await BackgroundLocationUpdates.stopTrackingLocation();
```

### Getting all unread Location Traces
Location traces should be primarily received through this method.

```dart
List<LocationTrace> traces = await BackgroundLocationUpdates.getUnreadLocationTraces();
```

This will retrieve all location traces that have not been previously marked as read. This means, you can call this method when your App is started in order to receive all Location Updates that happened in the time since your App was last opened. A List of Objects of type `LocationTrace` will be returned.

### Marking Location Traces as read
After you've processed the Unread Location Traces, you can mark them as read, so you won't receive them again by the `getUnreadLocationTraces` call in the future.

```dart
await BackgroundLocationUpdates.markAsRead(
    traces.map((trace) => trace.id).asList()
);
```

### Number of Traces
You can get the count of all traces recorded, or the count of all unread traces.

```dart
int unreadCount = await BackgroundLocationUpdates.getUnreadLocationTracesCount();
int totalCount = await BackgroundLocationUpdates.getLocationTracesCount();
```

### Keep informed about the State of the Plugin

```dart
BackgroundLocationUpdates.streamLocationActive().listen((bool state) {
    ...
});
```

### Getting the internal Sqlite DB Path

You can retrieve the path of the internal Sqlite Database used for storing the Location Traces, and use it for your own needs with something like [SqFlite](https://github.com/tekartik/sqflite).

```dart
final String db = await BackgroundLocationUpdates.getSqliteDatabasePath();
```

Here's the Schema used on both iOS and Android.

```sql
CREATE TABLE `location` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 
    `accuracy` REAL NOT NULL, 
    `longitude` REAL NOT NULL, 
    `latitude` REAL NOT NULL, 
    `altitude` REAL NOT NULL, 
    `time` INTEGER NOT NULL, 
    `read_count` INTEGER NOT NULL);
```


### Getting all Location Traces

```dart
List<LocationTrace> traces = await BackgroundLocationUpdates.getLocationTraces();
```

Receive all Location Traces that have ever been received by the Plugin. It's not recommended to use this method.

## FAQ

### I'm getting a SecurityException on Android when a new location is arriving

```
java.lang.SecurityException: Client must have ACCESS_COARSE_LOCATION or ACCESS_FINE_LOCATION permission to perform any location operations.
```

You forgot adding the required Permissions to your manifest. If you did, make sure to completely reinstall your app (hot reloads or restarts won't do, you must rerun `flutter run`) You even need this on Android O and above. See above for how to extend your manifest.

### The whole App is crashing on iOS when starting Location Tracking

Make sure you've added `location` to the `BackgroundModes` in your `Info.plist`.

### The App works on iOS, but nothing is happening

Make sure you've added all three Usage Descriptions to your `Info.plist`, as outlined above. If you have, run the App with XCode, look at the Log, and file an issue if you feel there is something wrong with this library.


For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).
