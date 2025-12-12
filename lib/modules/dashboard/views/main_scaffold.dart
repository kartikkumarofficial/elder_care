
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/controllers/auth_controller.dart';


import '../../caregiver/views/caregiver_dashboard.dart';
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
        Center(child: Text('Chat Screen')),
        LocationScreen(
          linkedUserId: (navController.linkedReceiverId.value.isNotEmpty)
              ? navController.linkedReceiverId.value
              : null,
        ),
        ProfileScreen(),
      ]
          : [
        CareReceiverDashboard(),

        // Chat
        Center(
          child: Text(
            'Chat Screen',
            style: TextStyle(color: Colors.white),
          ),
        ),

        // Tasks Screen (placeholder)
        Center(
          child: Text(
            'Tasks Screen (Receiver)',
            style: TextStyle(color: Colors.white),
          ),
        ),

        // Profile
        ProfileScreen(),
      ];


      return Scaffold(
        extendBody: true,
        backgroundColor: const Color(0xFF121212),
        body: screens[navController.selectedIndex.value],
        bottomNavigationBar: BottomNavBar(),
      );
    });
  }
}
