// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// ;
//
//
// class EditAccountPage extends StatelessWidget {
//   final EditAccountController accountController = Get.put(EditAccountController());
//
//   EditAccountPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.background,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(CupertinoIcons.back, color: Theme.of(context).colorScheme.onBackground),
//           onPressed: () => Get.back(result: true),
//         ),
//         title: Text(
//           'Edit Account',
//           style: GoogleFonts.poppins(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: Theme.of(context).colorScheme.onBackground,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           child: Obx(() => Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 20),
//               GestureDetector(
//                 onTap: accountController.pickImage,
//                 child: CircleAvatar(
//                   radius: Get.width * 0.22,
//                   backgroundColor: Theme.of(context).colorScheme.surface,
//                   backgroundImage: accountController.selectedImage.value != null
//                       ? FileImage(accountController.selectedImage.value!)
//                       : accountController.userController.profileImageUrl.value.isNotEmpty
//                       ? NetworkImage(accountController.userController.profileImageUrl.value)
//                       : const AssetImage('assets/default_profile.png') as ImageProvider,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               buildTextField(
//                 label: 'Name',
//                 controller: accountController.nameController,
//                 context: context,
//               ),
//               const SizedBox(height: 20),
//               buildTextField(
//                 label: 'Email',
//                 controller: accountController.emailController,
//                 context: context,
//               ),
//               const SizedBox(height: 30),
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: accountController.isLoading.value ? null : accountController.saveChanges,
//                   child: accountController.isLoading.value
//                       ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
//                       : Text(
//                     'Save Changes',
//                     style: GoogleFonts.barlow(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           )),
//         ),
//       ),
//     );
//   }
//
//   Widget buildTextField({
//     required String label,
//     required TextEditingController controller,
//     required BuildContext context,
//   }) {
//     return TextField(
//       controller: controller,
//       style: GoogleFonts.barlow(
//         color: Theme.of(context).colorScheme.onBackground,
//         fontSize: 16,
//       ),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: GoogleFonts.barlow(
//           color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
//           fontSize: 15,
//         ),
//         enabledBorder: UnderlineInputBorder(
//           borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
//         ),
//         focusedBorder: UnderlineInputBorder(
//           borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
//         ),
//       ),
//     );
//   }
// }