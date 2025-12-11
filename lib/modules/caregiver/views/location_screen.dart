import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/location_controller.dart';

class LocationScreen extends StatelessWidget {
  final String? linkedUserId;
  const LocationScreen({super.key, required this.linkedUserId});

  @override
  Widget build(BuildContext context) {
    if (linkedUserId == null || linkedUserId!.isEmpty) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.warning_amber_rounded, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No caregiver linked yet.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // controller MUST be created AFTER null check
    final controller =
    Get.put(LocationController(linkedUserId: linkedUserId!));

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.receiverLocation.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.receiverLocation.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_off_outlined,
                      size: 60, color: Colors.grey),
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

        return Stack(
          children: [
            FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(
                initialCenter: controller.receiverLocation.value!,
                initialZoom: 15.0,
                onMapReady: controller.onMapReady,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.eldercare',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: controller.receiverLocation.value!,
                      width: 80,
                      height: 80,
                      child: const Tooltip(
                        message: "Receiver's last known location",
                        child: Icon(Icons.location_pin,
                            size: 50, color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Top AppBar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                title: const Text("Receiver's Location"),
                backgroundColor: Colors.black.withOpacity(0.5),
                elevation: 0,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () =>
                        controller.fetchLocation(isRefresh: true),
                  ),
                ],
              ),
            ),

            // Bottom time-ago chip
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Obx(() {
                  final text = controller.timeAgo.value;
                  if (text.isEmpty) return const SizedBox.shrink();

                  return Chip(
                    avatar: const Icon(Icons.timer_outlined,
                        color: Colors.white70, size: 18),
                    label: Text(
                      text,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.black.withOpacity(0.7),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                  );
                }),
              ),
            ),
          ],
        );
      }),
    );
  }
}
