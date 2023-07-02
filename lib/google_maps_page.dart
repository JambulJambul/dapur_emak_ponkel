import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

typedef void GeoPointCallback(GeoPoint geoPoint);

class GoogleMapsPage extends StatefulWidget {
  final String mapContext;
  final GeoPointCallback? onGeoPointSelected;
  const GoogleMapsPage(
      {Key? key, required this.mapContext, this.onGeoPointSelected})
      : super(key: key);

  @override
  _GoogleMapsPageState createState() => _GoogleMapsPageState();
}

class _GoogleMapsPageState extends State<GoogleMapsPage> {
  GoogleMapController? _mapController;
  LatLng markerPosition =
      LatLng(-6.175544, 106.827649); // Initial marker position
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _saveMarkerPosition() {
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid;
    firestore
        .collection('users')
        .doc(uid)
        .update({
          'addressgeolocation':
              GeoPoint(markerPosition.latitude, markerPosition.longitude),
        })
        .then((value) => print('Marker position saved to Firestore'))
        .catchError((error) => print('Failed to save marker position: $error'));
  }

  void destinationPosition() {
    GeoPoint geoPoint =
        GeoPoint(markerPosition.latitude, markerPosition.longitude);
    widget.onGeoPointSelected!(geoPoint);
  }

  Future<void> _getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData? locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // Location services are disabled or not available
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        // Location permissions are not granted
        return;
      }
    }

    locationData = await location.getLocation();
    if (locationData != null) {
      setState(() {
        markerPosition = LatLng(
          locationData!.latitude ?? markerPosition.latitude,
          locationData.longitude ?? markerPosition.longitude,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFA500),
          title: const Text('Map Screen'),
        ),
        body: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: markerPosition,
            zoom: 15.0,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('marker_1'),
              position: markerPosition,
              draggable: true,
            ),
          },
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          onCameraMove: (CameraPosition position) {
            // Update the marker position as the camera moves
            setState(() {
              markerPosition = position.target;
            });
          },
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
          child: Container(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton(
              backgroundColor: Colors.orange,
              onPressed: () {
                if (widget.mapContext == "profile") {
                  _saveMarkerPosition();
                } else if (widget.mapContext == "destination") {
                  destinationPosition();
                }
                Navigator.pop(context);
              },
              child: Text('Done'),
            ),
          ),
        ));
  }
}
