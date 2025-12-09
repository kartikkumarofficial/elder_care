import 'package:elder_care/presentation/widgets/vital_status_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/caregiver_dashboard_controller.dart';

class CaregiverDashboard extends StatefulWidget {
  CaregiverDashboard({super.key});

  @override
  State<CaregiverDashboard> createState() => _CaregiverDashboardState();
}

class _CaregiverDashboardState extends State<CaregiverDashboard> {

  final controller = Get.put(CaregiverDashboardController());

  @override
  Widget build(BuildContext context) {
    final srch=Get.height;
    final srcw=Get.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (!controller.isMapReady.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // =================== MAP + PANEL STACK ===================
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // MAP
                  SizedBox(
                    height: Get.height * 0.42,
                    width: double.infinity,
                    child: GoogleMap(
                      markers: {
                        Marker(
                          markerId: const MarkerId("receiver"),
                          position: LatLng(
                            controller.lat.value,
                            controller.lng.value,
                          ),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRed),
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
                        Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer()),
                      },
                    ),
                  ),

                  // WHITE PANEL
                  Positioned(
                    top: Get.height * 0.28,
                    left: 0,
                    right: 0,
                    child: Container(
                      // padding:  EdgeInsets.only(left:Get.width*0.04),
                      decoration: const BoxDecoration(

                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          //title and location
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                      SizedBox(width:srcw*0.35), // offset for profile image
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: srch*0.01,),
                          Text(
                            controller.name.value,
                            style: GoogleFonts.nunito(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height:srch*0.0001),
                          Text(
                            "Location refreshed ${controller.lastLocationRefresh.value}",
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      ],
                    ),
                           SizedBox(height:srch*0.01),
                          _watchStatusSection(),
                          const SizedBox(height: 25),
                          _healthStatusSection(),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),

                  // PROFILE PICTURE inside the white panel
                  Positioned(
                    top: Get.height * 0.24,
                    left: 20,
                    child: Container(
                      width: 85,
                      height: 85,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: controller.profileUrl.value.isEmpty
                            ? Image.asset("assets/images/def_png.png", fit: BoxFit.cover)
                            : Image.network(controller.profileUrl.value, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Bottom Action Buttons (Call, Emergency, Caregivers)
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 20),
              //   child: _actionButtons(),
              // ),

              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  // ================= HEADER (Name + Subtitle) =================
  Widget _headerSection() {
    return Row(
      children: [
        const SizedBox(width: 100), // offset for profile image
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.name.value,
              style: GoogleFonts.nunito(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Location refreshed ${controller.lastLocationRefresh.value}",
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ================= WATCH STATUS SECTION =================
  Widget _watchStatusSection() {
    return Obx(() {
      final connected = controller.fitbitConnected.value;
      final battery = controller.battery.value;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: Get.width * 0.06),
        child: Row(
          children: [
            // ========== Wearable Status (Icon + Text) ==========
            Row(
              children: [
                Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: connected
                        ? Colors.teal.shade100
                        : Colors.red.shade100,
                  ),
                  child: Icon(
                    connected
                        ? Icons.watch  // wearable icon
                        : Icons.watch_off, // wearable disconnected
                    color: connected
                        ? Colors.teal.shade700
                        : Colors.red.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  connected
                      ? "Wearable Connected"
                      : "No Wearable Detected",
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // ========== Battery Indicator ==========
            Row(
              children: [
                Icon(
                  Icons.battery_full,
                  size: 22,
                  color: battery > 40 ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  "$battery%",
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 16),

            // ========== Refresh Button ==========
            ElevatedButton(
              onPressed: controller.refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade50,
                foregroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
              child: Text(
                "Refresh",
                style: GoogleFonts.nunito(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ================= HEALTH STATUS =================
  Widget _healthStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "HEALTH STATUS",
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            VitalStatusCard(
              icon: Icons.favorite,
              value: "${controller.heartRate.value} bpm",
              label: "Heart Rate",
              iconColor: Colors.redAccent,
            ),
            VitalStatusCard(
              icon: Icons.warning_amber_rounded,
              value: controller.fallDetected.value ? "Fall!" : "No Fall",
              label: "Fall",
              iconColor: controller.fallDetected.value ? Colors.orange : Colors.green,
            ),
            VitalStatusCard(
              icon: Icons.water_drop,
              value: "${controller.oxygen.value}%",
              label: "Oxygen",
              iconColor: Colors.blueAccent,
            ),
          ],
        )
      ],
    );
  }

  // ================= ACTION BUTTONS =================
  Widget _actionButton(IconData icon, String label) {
    return Expanded(
      child: Container(
        height: 90,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: Colors.blueGrey),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
