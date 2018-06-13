import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:background_location_updates/background_location_updates.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  Color startTrackingButtonColor = Colors.grey;
  Color isActiveColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await BackgroundLocationUpdates.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    BackgroundLocationUpdates.streamLocationActive().listen((bool state) {
      setState(() {
        if (state) {
          isActiveColor = Colors.green;
        } else {
          isActiveColor = Colors.red;
        }
      });
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Center(
            child: new Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: new RaisedButton(
                color: this.startTrackingButtonColor,
                onPressed: () async {
                  bool loc =
                      await BackgroundLocationUpdates.startTrackingLocation(
                          BackgroundLocationUpdates.LOCATION_SINK_SQLITE,
                          requestInterval: const Duration(seconds: 10));
                  setState(() {
                    if (loc) {
                      this.startTrackingButtonColor = Colors.green;
                    } else {
                      this.startTrackingButtonColor = Colors.red;
                    }
                  });
                },
                child: const Text('startTrackingLocation(10s)'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: new RaisedButton(
                onPressed: () {
                  BackgroundLocationUpdates.stopTrackingLocation();
                },
                child: const Text('stopTrackingLocation()'),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: new RaisedButton(
                  child: const Text('Is active?'),
                  color: isActiveColor,
                  onPressed: () async {},
                )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: new RaisedButton(
                child: const Text('Request Permission'),
                onPressed: () async {
                  await BackgroundLocationUpdates.requestPermission();
                },
              ),
            )
          ],
        )),
      ),
    );
  }
}
