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
        padding: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
        child: Row(
          children: [
            // -------- Wearable Status --------
            Flexible(
              child: Row(
                children: [
                  Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: connected ? Colors.teal.shade100 : Colors.red.shade100,
                    ),
                    child: Icon(
                      connected ? Icons.watch : Icons.watch_off,
                      color: connected ? Colors.teal.shade700 : Colors.red.shade700,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Make text wrap if needed (prevents overflow)
                  Expanded(
                    child: Text(
                      connected ? "Wearable Connected" : "No Wearable Detected",
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // -------- Battery --------
            Row(
              children: [
                Icon(
                  Icons.battery_full,
                  size: 20,
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

            const SizedBox(width: 8),

            // -------- Refresh Button (more compact) --------
            SizedBox(
              height: 32,
              child: Obx(() {
                final refreshing = controller.isRefreshing.value;

                return OutlinedButton(
                  onPressed: refreshing ? null : controller.refreshData,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.blue.shade300, width: 1),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: refreshing
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Refreshing...",
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  )
                      : Text(
                    "Refresh",
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue.shade700,
                    ),
                  ),
                );
              }),
            ),

          ],
        ),
      );
    });
  }


  // ================= HEALTH STATUS =================
  Widget _healthStatusSection() {
    final hr = controller.heartRate.value == "--"
        ? "--"
        : "${controller.heartRate.value} bpm";

    final oxy = controller.oxygen.value == "--"
        ? "--"
        : "${controller.oxygen.value}%";

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "HEALTH STATUS",
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),

          // 🔥 Scrollable section only around the row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            child: Row(
              children: [
                _healthCard(
                  icon: Icons.favorite,
                  iconColor: Colors.redAccent,
                  label: "Heart Rate",
                  value: hr,
                  gradient: [
                    Colors.redAccent.withOpacity(0.18),
                    Colors.redAccent.withOpacity(0.08),
                  ],
                ),
                const SizedBox(width: 12),

                _healthCard(
                  icon: Icons.warning_amber_rounded,
                  iconColor: controller.fallDetected.value ? Colors.orange : Colors.green,
                  label: "Fall",
                  value: controller.fallDetected.value ? "Fall Detected" : "No Fall",
                  gradient: [
                    Colors.orange.withOpacity(0.18),
                    Colors.orange.withOpacity(0.08),
                  ],
                ),
                const SizedBox(width: 12),

                _healthCard(
                  icon: Icons.directions_walk,
                  iconColor: Colors.deepPurple,
                  label: "Steps",
                  value: controller.steps.value == "--"
                      ? "--"
                      : controller.steps.value.toString(),
                  gradient: [
                    Colors.deepPurple.withOpacity(0.18),
                    Colors.deepPurple.withOpacity(0.08),
                  ],
                ),
                const SizedBox(width: 12),

                _healthCard(
                  icon: Icons.water_drop_rounded,
                  iconColor: Colors.blueAccent,
                  label: "Oxygen",
                  value: oxy,
                  gradient: [
                    Colors.blueAccent.withOpacity(0.18),
                    Colors.blueAccent.withOpacity(0.08),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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


Widget _healthCard({
  required IconData icon,
  required Color iconColor,
  required String label,
  required String value,
  required List<Color> gradient,
}) {
  return Container(
    width: Get.width * 0.32,   // matches your exact current look but ensures overflow
    // auto responsive
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradient,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // icon chip
        Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.9),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),

        const SizedBox(height: 12),

        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ],
    ),
  );
}
