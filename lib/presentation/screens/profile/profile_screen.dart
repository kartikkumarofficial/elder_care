// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// import '../../../app/controllers/theme_controller.dart';
// import '../../../app/controllers/user_controller.dart';
// import '../../widgets/profile_tile.dart';
// import 'edit_accountdetails_screen.dart';
//
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> {
//   final ThemeController themeController = Get.find();
//   final UserController userController = Get.find<UserController>();
//
//   @override
//   void initState() {
//     super.initState();
//     userController.fetchUserProfile();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.background,
//       body: RefreshIndicator(
//         onRefresh: userController.fetchUserProfile,
//         child: Obx(() => userController.isLoading.value
//             ? const Center(child: CircularProgressIndicator())
//             : ListView(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           children: [
//             const SizedBox(height: 50),
//             Center(
//               child: CircleAvatar(
//                 radius: Get.width * 0.17,
//                 backgroundImage: userController.profileImageUrl.value.isNotEmpty
//                     ? NetworkImage(userController.profileImageUrl.value)
//                     : const AssetImage('assets/default_profile.png') as ImageProvider,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Center(
//               child: Text(
//                 userController.userName.value,
//                 style: GoogleFonts.poppins(
//                   fontSize: 25,
//                   fontWeight: FontWeight.bold,
//                   color: Theme.of(context).colorScheme.onBackground,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 4),
//             Center(
//               child: Text(
//                 userController.email.value,
//                 style: GoogleFonts.barlow(color: Colors.grey[600]),
//               ),
//             ),
//             SizedBox(height: Get.height * 0.1),
//             ProfileTile(
//               onTap: () async {
//                 final result = await Get.to(() => EditAccountPage());
//                 if (result == true) {
//                   userController.fetchUserProfile();
//                 }
//               },
//               icon: Icons.settings,
//               label: "Edit Account Details",
//             ),
//             Obx(() => ProfileTile(
//               icon: Icons.brightness_6,
//               label: themeController.isDarkMode.value
//                   ? "Switch to Light Mode"
//                   : "Switch to Dark Mode",
//               onTap: themeController.toggleTheme,
//             )),
//             ProfileTile(
//               icon: Icons.lock,
//               label: "Security",
//               onTap: () {},
//             ),
//             const SizedBox(height: 24),
//             TextButton.icon(
//               onPressed: userController.logout,
//               icon: const Icon(Icons.logout, color: Colors.redAccent),
//               label: const Text(
//                 'Log Out',
//                 style: TextStyle(color: Colors.redAccent),
//               ),
//             ),
//             const SizedBox(height: 12),
//             Center(
//               child: Text(
//                 "v1.0.0 • YAP",
//                 style: TextStyle(color: Colors.grey[500]),
//               ),
//             ),
//             const SizedBox(height: 24),
//           ],
//         )),
//       ),
//     );
//   }
// }