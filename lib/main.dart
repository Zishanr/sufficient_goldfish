import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';

// TODO: Better populate these
const double targetLatitude = 37.785844;
const double targetLongitude = -122.406427;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyProfilePage(), // TODO: remove big fat header.
    );
  }
}

class MyProfilePage extends StatelessWidget {
  MyProfilePage({Key key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new ListView(children: <Widget>[
          new Image.network('http://www.emilyfortuna.com/wp-content/uploads/2013/12/MG_0587smaller-683x1024.jpg'),

          new Text('Name: Emily'),
          new Text('Favorite Music: Beethoven'),
          new Center(
              child: new RaisedButton(
                  onPressed: () {
                    Navigator.of(context).push(new MaterialPageRoute<Null>(
                        builder: (BuildContext context) {
                          return new FinderPage(targetLatitude, targetLongitude);
                        }
                    ));
                  },
                  child: new Text("Find your fish!")
              )
          ),
        ],)
    );
  }
}

typedef void LocationCallback(Map<String, double> location);

class LocationTools {
  final Location location = new Location();

  Future<Map<String, double>> getLocation() {
    return location.getLocation;
  }

  void initListener(LocationCallback callback) {
    location.onLocationChanged.listen((Map<String,double> currentLocation) {
      callback(currentLocation);
    });
  }
}

class FinderPage extends StatefulWidget {
  final double targetLatitude;
  final double targetLongitude;

  FinderPage(this.targetLatitude, this.targetLongitude);

  @override
  _FinderPageState createState() => new _FinderPageState();
}

class _FinderPageState extends State<FinderPage> {
  LocationTools locationTools;
  double latitude = 0.0;
  double longitude = 0.0;
  double accuracy = 0.0;

  _FinderPageState() {
    locationTools = new LocationTools();
    locationTools.getLocation().then((Map<String, double> currentLocation) {
      _updateLocation(currentLocation);
    });
    locationTools.initListener(_updateLocation);
  }

  void _updateLocation(Map<String,double> currentLocation) {
    setState(() {
      latitude = currentLocation["latitude"];
      longitude = currentLocation["longitude"];
      accuracy = currentLocation["accuracy"];
    });
  }

  Color _colorFromLocationDiff() {
    int milesBetweenLines = 69;
    int feetInMile = 5280;
    int desiredFeetRange = 15;
    double multiplier = 2 * milesBetweenLines * feetInMile / desiredFeetRange;
    double latitudeDiff = (latitude - widget.targetLatitude).abs() * multiplier;
    double longitudeDiff = (longitude - widget.targetLongitude).abs() * multiplier;
    print(latitude);
    print(longitude);
    if (latitudeDiff > 1) {
      latitudeDiff = 1.0;
    }
    if (longitudeDiff > 1) {
      longitudeDiff = 1.0;
    }
    double totalDiff = (latitudeDiff + longitudeDiff) / 2;
    return Color.lerp(Colors.red, Colors.blue, totalDiff);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Find your fish!"),
        ),
        body: new Container(
          color: _colorFromLocationDiff(),
          child: new Center(
            child: new Image.asset('assets/location_ping.gif'),
          ),
        )
    );
  }
}
