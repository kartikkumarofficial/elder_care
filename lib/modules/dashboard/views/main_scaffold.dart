import 'package:elder_care/modules/care_receiver/views/schedule_screen.dart';
import 'package:elder_care/modules/care_receiver/widgets/sos_button.dart';
import 'package:elder_care/modules/care_receiver/widgets/sos_floating_button.dart';
import 'package:elder_care/modules/chat/views/chat_placeholder_screen.dart';
import 'package:elder_care/modules/chat/views/chat_screen.dart';
import 'package:elder_care/modules/chat/views/direct_chat.dart';
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


  late final List<Widget> caregiverScreens;
  late final List<Widget> receiverScreens;

  @override
  void initState() {
    super.initState();

    // Ensure controllers are available (NO recreation later)
    if (!Get.isRegistered<ReceiverDashboardController>()) {
      Get.lazyPut(() => ReceiverDashboardController());
    }

    caregiverScreens = [
      CaregiverDashboard(),
      // ChatPlaceholderScreen(),
      DirectChatScreen(),
      LocationScreen(
        linkedUserId: (navController.linkedReceiverId.value.isNotEmpty)
            ? navController.linkedReceiverId.value
            : null,
      ),
      ProfileScreen(),
    ];

    receiverScreens = [
      ReceiverDashboardScreen(),

      // Chat
      // ChatPlaceholderScreen(),

      // ChatScreen(),
      DirectChatScreen(),
      ScheduleScreen(),

      // Profile
      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final user = authController.user.value;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final screens =
    user.role == "caregiver" ? caregiverScreens : receiverScreens;

    return Scaffold(
      extendBody: true,
      // backgroundColor: const Color(0xFF121212),

      body: Obx(() {
        return IndexedStack(
          index: navController.selectedIndex.value,
          children: screens,
        );
      }),

      bottomNavigationBar: user.role == "caregiver"
          ? CareGiverBottomNavBar()
          : CareReceiverBottomNavBar(),

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

      /// ✅ FAB depends on selectedIndex → keep Obx here
      floatingActionButton: Obx(() {
        final rxUser = authController.user.value;

        if (rxUser == null || rxUser.role != 'receiver') {
          return const SizedBox.shrink();
        }

        final index = navController.selectedIndex.value;

        // 🏠 Receiver Home → SOS only
        if (index == 0) {
          return SOSFab(Get.find<ReceiverDashboardController>());
        }

        // 📅 Schedule → Add Task only
        if (index == 2) {
          return FloatingActionButton(
            heroTag: 'addTask',
            backgroundColor: kTeal,
            child: const Icon(Icons.add,color: Colors.white,),
            onPressed: () async {
              final currentIndex = navController.selectedIndex.value;

              final result = await _openAddDialog(context, isEdit: false);

              // restore tab index
              navController.selectedIndex.value = currentIndex;

              // ONLY refresh ScheduleScreen if task was added
              if (result == true) {
                // this triggers ScheduleScreen's Obx rebuild
                Get.find<ScheduleController>().loading.value = true;
                await Future.delayed(const Duration(milliseconds: 1));
                Get.find<ScheduleController>().loadForCurrentUser(
                  Get.find<ScheduleController>().selectedDate.value,
                );
              }
            },

          );
        }

        return const SizedBox.shrink();
      }),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
  Future<bool?> _openAddDialog(BuildContext ctx, {required bool isEdit}) {
    return showDialog<bool>(
      context: ctx,
      builder: (_) => AddEditTaskDialog(
        isEdit: isEdit,
        controller: Get.find<TaskController>(),
      ),
    );
  }

}
