# background_location_updates

Retrieve periodic location updates, even when the main App is not running. Useful for Navigation Apps to keep a rough idea of where the User is heading, and various other purposes. Please don't be evil though, and tell the User exactly how, when and why you wish to retrieve her location.

The Plugin uses `Background Location` on iOS, and a `WorkManager`-based Periodic Job, combined with a `OnBoot` Broadcast Receiver on Android.

**Currently doesn't work on iOS!**

## Getting Started

### Get the Package:

Add the following to your `pubspec.yml`:

```yaml
dependencies:
  background_location_updates: <<UNRELEASED>>
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

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).