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
import '../widgets/context_strip.dart';
import '../widgets/mood_dialog.dart';
import '../widgets/mood_section.dart';
import '../widgets/reciever_status_chip.dart';
import '../widgets/sos_button.dart';

class ReceiverDashboardScreen extends StatefulWidget {

  ReceiverDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ReceiverDashboardScreen> createState() => _ReceiverDashboardScreenState();
}

class _ReceiverDashboardScreenState extends State<ReceiverDashboardScreen> {
  @override
  void initState() {
    super.initState();

    ever(controller.shouldShowMoodDialog, (bool show) {
      if (show && !_dialogShown && mounted) {
        _dialogShown = true;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          MoodDialog.show(context);
        });
      }
    });
  }


  final ReceiverDashboardController controller = Get.put(ReceiverDashboardController(),permanent: true);
  bool _dialogShown = false;

  @override
  Widget build(BuildContext context) {

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (!controller.isLoading.value &&
    //       controller.shouldShowMoodDialog.value &&
    //       !_dialogShown) {
    //     _dialogShown = true;
    //     showMoodDialog(context);
    //   }
    // });



    final h = Get.height;
    final w = Get.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: ()=>ReceiverDashboardController().refreshDashboard(),
        child: Container(
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


                  SizedBox(height: h * 0.001),

                  /// DEVICE STATUS
                  ReceiverStatusChips(),


                  SizedBox(height: h * 0.01),

                  // sample data rn
                  ContextStrip(
                    items: [
                      ContextStripItem(
                        icon: Icons.event,
                        title: "Upcoming",
                        subtitle: "Doctor appointment at 6:00 PM",
                        color: Colors.teal,
                        onTap: () {
                          // Navigate to events
                        },
                      ),
                      ContextStripItem(
                        icon: Icons.medication,
                        title: "Reminder",
                        subtitle: "You haven’t taken your morning medicines",
                        color: Colors.orange,
                      ),
                      ContextStripItem(
                        icon: Icons.check_circle,
                        title: "All set",
                        subtitle: "You’re doing great today 😊",
                        color: Colors.green,
                      ),
                    ],
                  ),


                  /// EVENTS
                  EventSection(),

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
}
