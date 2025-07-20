// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import '../../controllers/health_analytics_controller.dart';
//
// class HealthAnalyticsScreen extends StatelessWidget {
//   final String linkedUserId;
//   const HealthAnalyticsScreen({Key? key, required this.linkedUserId}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     // Initialize the controller, passing the required linkedUserId
//     final HealthAnalyticsController controller = Get.put(HealthAnalyticsController(userId: linkedUserId));
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF2A2E43),
//       appBar: AppBar(
//         title: const Text("Health Summary"),
//         backgroundColor: const Color(0xFF2A2E43),
//         elevation: 0,
//       ),
//       body: RefreshIndicator(
//         onRefresh: () => controller.fetchLatestVitals(),
//         color: Colors.white,
//         backgroundColor: const Color(0xFF4A4E6C),
//         child: Obx(() {
//           if (controller.isLoading.value) {
//             return const Center(child: CircularProgressIndicator(color: Colors.white));
//           }
//           return ListView(
//             padding: const EdgeInsets.all(16.0),
//             children: [
//               _buildVitalCard(
//                 icon: Icons.favorite,
//                 color: Colors.redAccent,
//                 title: "Heart Rate",
//                 data: controller.latestVitals['Heart Rate'],
//                 unit: "BPM",
//               ),
//               const SizedBox(height: 16),
//               _buildVitalCard(
//                 icon: Icons.bloodtype,
//                 color: Colors.purpleAccent,
//                 title: "Blood Pressure",
//                 data: controller.latestVitals['Blood Pressure'],
//                 unit: "mmHg",
//               ),
//               const SizedBox(height: 16),
//               _buildVitalCard(
//                 icon: Icons.water_drop,
//                 color: Colors.tealAccent,
//                 title: "Sugar Level",
//                 data: controller.latestVitals['Sugar'],
//                 unit: "mg/dL",
//               ),
//             ],
//           );
//         }),
//       ),
//     );
//   }
//
//   /// A helper widget to build the individual analytics cards.
//   Widget _buildVitalCard({
//     required IconData icon,
//     required Color color,
//     required String title,
//     required Map<String, dynamic>? data,
//     required String unit,
//   }) {
//     String valueText = "N/A";
//     String timeText = "No data available";
//
//     // Safely parse the data from the controller's map
//     if (data != null && data['value'] != null) {
//       valueText = (data['value'] as num).toStringAsFixed(0);
//       if (data['timestamp'] != null) {
//         try {
//           final timestamp = DateTime.parse(data['timestamp']);
//           // Format to "Jul 20, 10:15 PM"
//           timeText = "Last updated: ${DateFormat.yMMMd().add_jm().format(timestamp)}";
//         } catch (e) {
//           timeText = "Invalid date format";
//         }
//       }
//     }
//
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xFF4A4E6C),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           )
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, color: color, size: 28),
//               const SizedBox(width: 12),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.baseline,
//             textBaseline: TextBaseline.alphabetic,
//             children: [
//               Text(
//                 valueText,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 48,
//                   fontWeight: FontWeight.w800,
//                   shadows: [Shadow(color: color.withOpacity(0.5), blurRadius: 10)],
//                 ),
//               ),
//               const SizedBox(width: 8),
//               if (data != null)
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 4.0),
//                   child: Text(
//                     unit,
//                     style: TextStyle(
//                       color: Colors.grey[300],
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             timeText,
//             style: TextStyle(
//               color: Colors.grey[400],
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
