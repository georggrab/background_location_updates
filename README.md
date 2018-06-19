# background_location_updates

Retrieve periodic location updates, even when the main App is not running. Useful for Navigation Apps to keep a rough idea of where the User is heading, and various other purposes. Please don't be evil though, and tell the User exactly how, when and why you wish to retrieve her location.

The Plugin uses `Significant Location Change` on iOS, and a `WorkManager`-based Periodic Job, combined with a `OnBoot` Broadcast Receiver on Android.

*This Plugin is heavily WIP, shouldn't be used in Production yet, and the API is likely to change by the hour.*

## Getting Started

### Get the Package:

Add the following to your `pubspec.yml`:

```yaml
dependencies:
  background_location_updates: ^0.1.0
```

### Android Permissions

In your `src/main/app/AndroidManifest.xml`, we'll need to register a couple permissions and a Broadcast Receiver.

```xml
<manifest ...">
    ....
    <!-- Alternatively: ACCESS_COARSE_LOCATION -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

    <application ...>
        .....
        <receiver android:name="io.gjg.backgroundlocationupdates.service.BootBroadcastReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
            </intent-filter>
        </receiver>
    </application>
</manifest>
```

## iOS Specifics

### Podfile & Swift Language Version

**You don't have to do this if you created your project with `flutter create ... -i swift`.**
This Plugin will only work with the Swift Podfile (get it from [here](https://github.com/flutter/flutter/blob/master/packages/flutter_tools/templates/cocoapods/Podfile-swift), replace `ios/Podfile`, delete `ios/Podfile.lock`). Afterwards you'll need to set the Swift Language Version to the latest one in the XCode Project if you haven't already. See [here](https://stackoverflow.com/questions/47743271/the-swift-language-version-swift-version-build-setting-error-with-project-in) for instructions.


### iOS Permissions
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

### Importing the Package

```dart
import 'package:background_location_updates/background_location_updates.dart';
```

### Requesting Permissions
```dart
await BackgroundLocationUpdates.requestPermission()
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

### Starting Location Tracking

After you've asked the User for appropriate permissions (read up on GDPR!), start the Location Tracking.

```dart
await BackgroundLocationUpdates
   .startTrackingLocation(
        BackgroundLocationUpdates.LOCATION_SINK_SQLITE,
        requestInterval: const Duration(seconds: 10));
```

The first argument to `startTrackingLocation` specifies how you which the Location to be persisted. Currently, only `SQLite` is supported. The second argument is a requestInterval, which specifies how often to ask the Operating System for the User's location. This will only be respected on Android, and even there, it will only have the desired effect on Versions below Android O. On Android O and below, this argument is ignored, and you will only receive new locations on the discretion of the Operating System, which is about three times an hour for both platforms.

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
```

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
