



import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CaregiverMap extends StatefulWidget {
  final double lat;
  final double lng;
  final void Function(GoogleMapController) onMapCreated;

  const CaregiverMap({
    super.key,
    required this.lat,
    required this.lng,
    required this.onMapCreated,
  });

  @override
  State<CaregiverMap> createState() => _CaregiverMapState();
}

class _CaregiverMapState extends State<CaregiverMap>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(
          widget.lat == 0 ? 20.5937 : widget.lat,
          widget.lng == 0 ? 78.9629 : widget.lng,
        ),
        zoom: 14,
      ),
      markers: {
        Marker(
          markerId: const MarkerId("receiver"),
          position: LatLng(widget.lat, widget.lng),
        ),
      },
      zoomControlsEnabled: false,
      onMapCreated: widget.onMapCreated,
    );
  }
}
