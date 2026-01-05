
import 'package:elder_care/modules/care_receiver/views/schedule_screen.dart';
import 'package:elder_care/modules/care_receiver/widgets/sos_button.dart';
import 'package:elder_care/modules/care_receiver/widgets/sos_floating_button.dart';
import 'package:elder_care/modules/chat/views/chat_placeholder_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/controllers/auth_controller.dart';


import '../../care_receiver/controllers/carereceiver_dashboard_controller.dart';
import '../../care_receiver/controllers/schedule_controller.dart';
import '../../caregiver/views/caregiver_dashboard.dart';
import '../../tasks/controllers/task_controller.dart';
import '../../tasks/views/task_section.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../controllers/nav_controller.dart';
import '../../profile/views/profile_screen.dart';
import '../../care_receiver/views/carereciever_dashboard.dart';
import '../../caregiver/views/location_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final NavController navController = Get.find<NavController>();
  final AuthController authController = Get.find<AuthController>();
  final SupabaseClient client = Supabase.instance.client;


  @override
  void initState() {
    super.initState();
    _loadLinkedReceiver();
  }


  Future<void> _loadLinkedReceiver() async {
    final user = authController.user.value;

    if (user == null || user.role != "caregiver") return;

    try {
      final result = await client
          .from('care_links')
          .select('receiver_id')
          .eq('caregiver_id', user.id)
          .maybeSingle();

      if (result != null && result['receiver_id'] != null) {
        navController.linkedReceiverId.value = result['receiver_id'];
      }
    } catch (e) {
      print("Error loading receiver ID: $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    return Obx(() {
      final user = authController.user.value;

      if (user == null) {
        return const Scaffold(
          backgroundColor: Color(0xFF121212),
          body: Center(child: CircularProgressIndicator()),
        );
      }


      final List<Widget> screens =
      user.role == "caregiver"
          ? [
        CaregiverDashboard(),
        ChatPlaceholderScreen(),
        LocationScreen(
          linkedUserId: (navController.linkedReceiverId.value.isNotEmpty)
              ? navController.linkedReceiverId.value
              : null,
        ),
        ProfileScreen(),
      ]
          : [
        ReceiverDashboardScreen(),

        // Chat
        ChatPlaceholderScreen(),

        ScheduleScreen(),

        // Profile
        ProfileScreen(),
      ];


      return Scaffold(
        extendBody: true,
        // backgroundColor: const Color(0xFF121212),
        body: screens[navController.selectedIndex.value],
        bottomNavigationBar: user.role == "caregiver" ? CareGiverBottomNavBar():CareReceiverBottomNavBar(),
        // floatingActionButton: user.role == 'receiver'
        //     ? SOSFab(Get.put(ReceiverDashboardController()))
        //     : null,

        // approach 2
        //   floatingActionButton: Obx(() {
        //
        //     if (user.role != 'receiver') return const SizedBox.shrink();
        //
        //     if (navController.selectedIndex.value != 2) {
        //       return SOSFab(Get.put(ReceiverDashboardController()));
        //     }
        //
        //     return Column(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         FloatingActionButton(
        //           heroTag: 'addTask',
        //           backgroundColor: kTeal,
        //           child: const Icon(Icons.add),
        //           onPressed: () async {
        //             final taskController = Get.find<TaskController>();
        //
        //             await Get.dialog(
        //               AddEditTaskDialog(
        //                 isEdit: false,
        //                 controller: taskController,
        //               ),
        //             );
        //
        //             // refresh schedule after add
        //             Get.find<ScheduleController>().loadForCurrentUser(
        //               Get.find<ScheduleController>().selectedDate.value,
        //             );
        //           },
        //         ),
        //         const SizedBox(height: 12),
        //
        //         // SOS always below
        //         SOSFab(Get.put(ReceiverDashboardController())),
        //       ],
        //     );
        //   }),

        floatingActionButton: Obx(() {
          // Only for receiver
          if (user.role != 'receiver') {
            return const SizedBox.shrink();
          }

          final index = navController.selectedIndex.value;

          // 🏠 Receiver Home → SOS only
          if (index == 0) {
            return SOSFab(Get.put(ReceiverDashboardController()));
          }

          // 📅 Schedule → Add Task only
          if (index == 2) {
            return FloatingActionButton(
              heroTag: 'addTask',
              backgroundColor: kTeal,
              child: const Icon(Icons.add),
              onPressed: () async {
                final taskController = Get.find<TaskController>();

                await Get.dialog(
                  AddEditTaskDialog(
                    isEdit: false,
                    controller: taskController,
                  ),
                );

                // Refresh schedule
                Get.find<ScheduleController>().loadForCurrentUser(
                  Get.find<ScheduleController>().selectedDate.value,
                );
              },
            );
          }

          // ❌ Any other screen → no FAB
          return const SizedBox.shrink();
        }),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        
      );
    });
  }
}