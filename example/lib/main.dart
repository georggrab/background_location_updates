import 'package:flutter/material.dart';
import 'dart:async';

import 'package:background_location_updates/background_location_updates.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<LocationTrace> traces = [];
  int tracesCount;
  String _permissionState;
  Color isActiveColor = Colors.grey;
  String sqlitePath = "SqlitePath";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    BackgroundLocationUpdates.streamLocationActive().first;
    BackgroundLocationUpdates.streamLocationActive().listen((bool state) {
      print('State: $state');
      setState(() {
        if (state) {
          isActiveColor = Colors.green;
        } else {
          isActiveColor = Colors.red;
        }
      });
    });

    BackgroundLocationUpdates
        .getPermissionState()
        .listen((PermissionState state) {
      setState(() {
        _permissionState = state.toString();
      });
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  void updateUnread() async {
    int traces = await BackgroundLocationUpdates.getUnreadLocationTracesCount();
    var unread = await BackgroundLocationUpdates.getUnreadLocationTraces();
    setState(() {
      tracesCount = traces;
      this.traces = unread;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('background_location_updates'),
        ),
        body: Container(
          child: new Column(
            children: <Widget>[
              Wrap(
                children: <Widget>[
                  new RaisedButton(
                    onPressed: () async {
                      await BackgroundLocationUpdates.startTrackingLocation(
                          iOSStrategy: IOSSignificantLocationChangeStrategy(
                              desiredAccuracy: IOSStrategy.ACCURACY_BEST),
                          androidStrategy: AndroidBroadcastBasedRequestStrategy(
                              requestInterval: const Duration(seconds: 30)));
                    },
                    child: const Text('a:broadcast;i:slc(30s)'),
                  ),
                  new RaisedButton(
                    onPressed: () async {
                      await BackgroundLocationUpdates.startTrackingLocation(
                          iOSStrategy: IOSLocationChangeStrategy(
                              desiredAccuracy: IOSStrategy.ACCURACY_BEST),
                          androidStrategy: AndroidPeriodicRequestStrategy(
                              requestInterval: const Duration(seconds: 10)));
                    },
                    child: const Text('a:periodic;i:lc(10s)'),
                  ),
                  new RaisedButton(
                    onPressed: () {
                      BackgroundLocationUpdates.stopTrackingLocation();
                    },
                    child: const Text('stopTrackingLocation()'),
                  ),
                  new RaisedButton(
                    child: const Text('Is active?'),
                    color: isActiveColor,
                    onPressed: () {},
                  ),
                  new RaisedButton(
                    child: const Text('Request Permission'),
                    onPressed: () async {
                      await BackgroundLocationUpdates.requestPermission();
                    },
                  ),
                  new RaisedButton(
                    child: new Text("Unread Location Traces: $tracesCount"),
                    onPressed: () async {
                      this.updateUnread();
                    },
                  ),
                  new RaisedButton(
                    child: new Text("$sqlitePath"),
                    onPressed: () async {
                      String path = await BackgroundLocationUpdates
                          .getSqliteDatabasePath();
                      setState(() {
                        sqlitePath = path;
                      });
                    },
                  ),
                  new RaisedButton(
                    child: new Text("Mark all displayed unread as read"),
                    onPressed: () async {
                      List<int> ids = this.traces.map((LocationTrace trace) {
                        return trace.id;
                      }).toList();
                      await BackgroundLocationUpdates.markAsRead(ids);
                      this.updateUnread();
                    },
                  ),
                  new Text('Permission State: $_permissionState'),
                ],
              ),
              Flexible(
                child: ListView.builder(
                  itemCount: traces.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (index < traces.length) {
                      return new ExpansionTile(
                        title: new Text('Trace #$index'),
                        children: <Widget>[
                          new ListTile(
                            title: new Text('Latitude'),
                            subtitle: new Text('${traces[index].latitude}'),
                          ),
                          new ListTile(
                            title: new Text('Longitude'),
                            subtitle: new Text('${traces[index].longitude}'),
                          ),
                          new ListTile(
                            title: new Text('Altitude'),
                            subtitle: new Text('${traces[index].altitude}'),
                          ),
                          new ListTile(
                            title: new Text('All'),
                            subtitle: new Text('${traces[index].toString()}'),
                          ),
                        ],
                      );
                    } else {
                      return null;
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
