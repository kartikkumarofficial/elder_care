
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../events/views/eventssection.dart';
import '../widgets/healthstatussection.dart';
import '../../tasks/views/task_section.dart';
import '../controllers/caregiver_dashboard_controller.dart';
import '../widgets/watchstatusSection.dart';

class CaregiverDashboard extends StatefulWidget {
  CaregiverDashboard({super.key});

  @override
  State<CaregiverDashboard> createState() => _CaregiverDashboardState();
}

class _CaregiverDashboardState extends State<CaregiverDashboard> {

  final controller = Get.put(CaregiverDashboardController());


  @override
  Widget build(BuildContext context) {
    final receiverId = controller.receiverId.value;
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
              Container(
                child: Stack(
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
                      // top: Get.height * 0.28,
                      bottom: 0,
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



                          ],
                        ),
                      ),
                    ),

                    // PROFILE PICTURE inside the white panel
                    Positioned(
                      // top: Get.height * 0.24,
                      bottom: srch*0.03,
                      left: srcw*.08,
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
              ),

              // const SizedBox(height: 30),
              SizedBox(height:srch*0.01),
              watchStatusSection(),
              SizedBox(height:srch*0.01),
              healthStatusSection(),
              // SizedBox(height:srch*0.01),
              SizedBox(height: srch * 0.015),
              EventSectionModern(),
              SizedBox(height: srch * 0.02),

              TaskSection(),




              // Bottom Action Buttons (Call, Emergency, Caregivers)


              const SizedBox(height: 200),
            ],
          ),
        );
      }),
    );
  }




}



