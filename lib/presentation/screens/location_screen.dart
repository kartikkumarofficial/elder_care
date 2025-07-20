import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../controllers/location_controller.dart';

class LocationScreen extends StatelessWidget {
  final String linkedUserId;
  const LocationScreen({super.key, required this.linkedUserId});

  @override
  Widget build(BuildContext context) {
    final LocationController controller = Get.put(LocationController(linkedUserId: linkedUserId));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Receiver's Location"),
        backgroundColor: Colors.grey[900],
        elevation: 0,
        actions: [
          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchLocation(isRefresh: true),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.receiverLocation.value == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Location data not available. Please ask the user to start sharing or try refreshing.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        }

        return FlutterMap(
          mapController: controller.mapController,
          options: MapOptions(
            initialCenter: controller.receiverLocation.value!,
            initialZoom: 15.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.yourapp.packagename',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: controller.receiverLocation.value!,
                  width: 80,
                  height: 80,
                  child: const Tooltip(
                    message: "Receiver's last known location",
                    child: Icon(Icons.location_pin, size: 50, color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
  