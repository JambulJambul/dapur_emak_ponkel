import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapPageFixed extends StatefulWidget {
  final GeoPoint markerKey;

  const GoogleMapPageFixed({Key? key, required this.markerKey})
      : super(key: key);

  @override
  _GoogleMapPageFixedState createState() => _GoogleMapPageFixedState();
}

class _GoogleMapPageFixedState extends State<GoogleMapPageFixed> {
  late GoogleMapController _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFA500),
        title: Text('Destination Pin'),
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.markerKey.latitude, widget.markerKey.longitude),
          zoom: 15.0,
        ),
        markers: {
          Marker(
              markerId: const MarkerId('marker_1'),
              position:
                  LatLng(widget.markerKey.latitude, widget.markerKey.longitude),
              draggable: false)
        },
      ),
    );
  }
}
