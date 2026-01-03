import 'package:elder_care/modules/care_receiver/widgets/receiver_battery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../caregiver/widgets/statussection.dart';
import '../../events/views/eventssection.dart';
import '../../tasks/views/task_section.dart';
import '../controllers/carereceiver_dashboard_controller.dart';
import '../widgets/mood_section.dart';
import '../widgets/sos_button.dart';

class ReceiverDashboardScreen extends StatelessWidget {
  final ReceiverDashboardController controller = Get.put(ReceiverDashboardController(),permanent: true);
  ReceiverDashboardScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final h = Get.height;
    final w = Get.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: h,
        width: w,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/auth/login_bg.png"),
            fit: BoxFit.cover,
            opacity: 0.05,
          ),
          gradient: LinearGradient(
            colors: [Color(0xFFeaf4f2), Color(0xFFfdfaf6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Obx(
              () => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              // horizontal: w * 0.01,
              vertical: h * 0.04,

            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// GREETING
                SizedBox(height: h * 0.01),
                ReceiverHeaderSection(w,h),

                SizedBox(height: h * 0.03),

                /// MOOD
                moodSection(w, h),

                SizedBox(height: h * 0.03),

                /// DEVICE STATUS
                BatterySection(),


                SizedBox(height: h * 0.03),

                /// EVENTS
                EventSectionModern(),

                SizedBox(height: h * 0.03),

                /// TASKS
                TaskSection( receiverIdOverride: controller.supabase.auth.currentUser!.id,),

                // SizedBox(height: h * 0.045),

                /// SOS
                // sosButton(w, h),

                SizedBox(height: h * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget ReceiverHeaderSection(double w , double h){
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: w*0.05),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                controller.greeting,
                style: GoogleFonts.nunito(
                  fontSize: w * 0.045,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(onPressed: (){
                //todo implement notif screen
              }, icon:Icon(CupertinoIcons.bell))
            ],
          ),
          Text(
            controller.userName.value,
            style: GoogleFonts.nunito(
              fontSize: w * 0.065,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }



  //header


  // MOOD SECTION



  // ─────────────────────────────────────────────
  // SOS BUTTON
  // ─────────────────────────────────────────────

}
