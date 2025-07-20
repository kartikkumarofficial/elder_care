// views/location_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:elder_care/services/location_service.dart';

class LocationScreen extends StatefulWidget {
  final String linkedUserId;

  const LocationScreen({super.key, required this.linkedUserId});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  LatLng? receiverLocation;

  @override
  void initState() {
    super.initState();
    fetchLocation();
  }

  void fetchLocation() async {
    final locationService = LocationService();
    final data = await locationService.getLocationOfLinkedUser(widget.linkedUserId);

    if (data != null && data['latitude'] != null && data['longitude'] != null) {
      setState(() {
        receiverLocation = LatLng(data['latitude'], data['longitude']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: receiverLocation == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: receiverLocation!,
          zoom: 14,
        ),
        markers: {
          Marker(
            markerId: MarkerId('receiver'),
            position: receiverLocation!,
          ),
        },
      ),
    );
  }
}
