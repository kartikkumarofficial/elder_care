import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/caregiver_dashboard_controller.dart';

class CaregiverDashboard extends StatelessWidget {
  CaregiverDashboard({super.key});

  final controller = Get.put(CaregiverDashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Obx(() {
        if (!controller.isMapReady.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: Get.height * 0.36,
              pinned: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    GoogleMap(
                      markers: {
                        Marker(
                          markerId: MarkerId("receiver"),
                          position: LatLng(controller.lat.value, controller.lng.value),
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                        ),
                      },

                      initialCameraPosition: CameraPosition(

                        target: LatLng(
                          controller.lat.value == 0 ? 20.5937 : controller.lat.value,
                          controller.lng.value == 0 ? 78.9629 : controller.lng.value,
                        ),
                        zoom: 14,
                      ),
                      onMapCreated: controller.onMapCreated,
                      zoomControlsEnabled: false,
                      gestureRecognizers: {
                        Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
                      },
                    ),

                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),

                    Positioned(
                      left: 20,
                      bottom: 25,
                      child: Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.name.value,
                            style: GoogleFonts.nunito(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Location updated ${controller.lastLocationRefresh.value}",
                            style: GoogleFonts.nunito(color: Colors.white70),
                          ),
                        ],
                      )),
                    ),

                    Positioned(
                      right: 20,
                      bottom: 20,
                      child: CircleAvatar(
                        radius: 38,
                        backgroundColor: Colors.white,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: controller.profileUrl.value.isEmpty
                              ? Image.asset("assets/images/def_png.png")
                              : Image.network(controller.profileUrl.value),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _sectionTitle("Device Status"),
                    _deviceStatusCard(),
                    const SizedBox(height: 22),

                    _sectionTitle("Health Status"),
                    _healthGrid(),
                    const SizedBox(height: 22),

                    _featureCard("Appointment Scheduler (coming soon)", Icons.event),
                    const SizedBox(height: 14),

                    _featureCard("Task Scheduler (coming soon)", Icons.list_alt),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w700),
    );
  }

  Widget _deviceStatusCard() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _box(),
        child: Row(
          children: [
            Icon(
              controller.fitbitConnected.value ? Icons.watch : Icons.watch_off,
              color: controller.fitbitConnected.value ? Colors.green : Colors.red,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              controller.fitbitConnected.value ? "Fitbit Connected" : "Fitbit Not Connected",
              style: GoogleFonts.nunito(fontSize: 16),
            ),
            const Spacer(),
            Icon(Icons.battery_full,
                color: controller.battery.value > 40 ? Colors.green : Colors.orange),
            const SizedBox(width: 5),
            Text("${controller.battery.value}%"),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: controller.refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7AB7A7),
                shape: const StadiumBorder(),
              ),
              child: const Text("Refresh"),
            ),
          ],
        ),
      );
    });
  }

  Widget _healthGrid() {
    return Obx(() {
      return GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _healthCard(Icons.favorite, controller.heartRate.value, "Heart Rate", Colors.red),
          _healthCard(
            Icons.warning,
            controller.fallDetected.value ? "Fall!" : "Normal",
            "Fall Status",
            controller.fallDetected.value ? Colors.orange : Colors.green,
          ),
          _healthCard(Icons.water_drop, controller.oxygen.value, "Oxygen", Colors.blue),
        ],
      );
    });
  }

  Widget _healthCard(IconData icon, String value, String label, Color color) {
    return Container(
      decoration: _box(),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(label, style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _featureCard(String label, IconData icon) {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6EFE3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.brown, size: 30),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.nunito(fontSize: 16)),
        ],
      ),
    );
  }

  BoxDecoration _box() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
        )
      ],
    );
  }
}
