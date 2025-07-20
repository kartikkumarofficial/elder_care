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
      body: Obx(() {
        // Show a loading indicator only on the initial load
        if (controller.isLoading.value && controller.receiverLocation.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show an informative message if no location has ever been found
        if (controller.receiverLocation.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_off_outlined, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Location data not available.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Refreshing'),
                    onPressed: () => controller.fetchLocation(isRefresh: true),
                  )
                ],
              ),
            ),
          );
        }

        // Use a Stack to overlay UI elements on the map
        return Stack(
          children: [
            FlutterMap(
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
            ),
            // Positioned AppBar at the top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                title: const Text("Receiver's Location"),
                backgroundColor: Colors.black.withOpacity(0.5), // Semi-transparent
                elevation: 0,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => controller.fetchLocation(isRefresh: true),
                  ),
                ],
              ),
            ),
            // Positioned "Time Ago" chip at the bottom
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.center,
                child: Obx(() => controller.timeAgo.value.isEmpty
                    ? const SizedBox.shrink() // Don't show if empty
                    : Chip(
                  avatar: Icon(Icons.timer_outlined, color: Colors.white70, size: 18),
                  label: Text(
                    controller.timeAgo.value,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.black.withOpacity(0.7),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
