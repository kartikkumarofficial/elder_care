// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../controllers/connect_reciever_controller.dart';
//
// class ConnectReceiverView extends StatelessWidget {
//   final CareConnectionController controller =  Get.put(ConnectReceiverController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF2A2E43),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF4A4E6C),
//         title: const Text(
//           'Connect with Receiver',
//           style: TextStyle(color: Colors.white),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Enter Receiver ID',
//               style: TextStyle(color: Colors.white70, fontSize: 16),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: controller.receiverIdController,
//               style: const TextStyle(color: Colors.white),
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: const Color(0xFF4A4E6C),
//                 hintText: 'Receiver UUID',
//                 hintStyle: const TextStyle(color: Colors.white54),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: controller.connectWithReceiver,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF4A4E6C),
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text(
//                   'Connect',
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
