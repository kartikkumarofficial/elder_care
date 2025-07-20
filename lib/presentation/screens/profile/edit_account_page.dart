// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
//
//
// class EditProfileScreen extends StatelessWidget {
//   EditProfileScreen({super.key});
//
//   final EditProfileController controller = Get.put(EditProfileController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF2A2E43),
//       appBar: AppBar(
//         title: const Text("Edit Profile"),
//         backgroundColor: const Color(0xFF2A2E43),
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           children: [
//             const SizedBox(height: 20),
//             Obx(() => GestureDetector(
//               onTap: controller.pickImage,
//               child: CircleAvatar(
//                 radius: Get.width * 0.2,
//                 backgroundColor: Colors.grey[800],
//                 backgroundImage: controller.selectedImage.value != null
//                     ? FileImage(controller.selectedImage.value!)
//                     : NetworkImage(controller.authController.user.value?.profileImage ?? '') as ImageProvider,
//                 child: const Align(
//                   alignment: Alignment.bottomRight,
//                   child: CircleAvatar(
//                     radius: 20,
//                     backgroundColor: Colors.deepPurpleAccent,
//                     child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
//                   ),
//                 ),
//               ),
//             )),
//             const SizedBox(height: 40),
//             TextField(
//               controller: controller.nameController,
//               style: const TextStyle(color: Colors.white),
//               decoration: InputDecoration(
//                 labelText: "Full Name",
//                 labelStyle: TextStyle(color: Colors.grey[400]),
//                 filled: true,
//                 fillColor: const Color(0xFF4A4E6C),
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
//               ),
//             ),
//             const SizedBox(height: 40),
//             Obx(() => SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: controller.authController.isLoading.value ? null : controller.saveChanges,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.deepPurpleAccent,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//                 child: controller.authController.isLoading.value
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text("Save Changes", style: TextStyle(fontSize: 16, color: Colors.white)),
//               ),
//             )),
//           ],
//         ),
//       ),
//     );
//   }
// }
