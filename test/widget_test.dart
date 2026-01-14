// Widget scheduleHeader({
//   required int completed,
//   required int total,
// }) {
//   final percent = total == 0 ? 0.0 : completed / total;
//
//   return Container(
//     padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
//     decoration: const BoxDecoration(
//       color: Color(0xFFEAF4F2),
//       borderRadius: BorderRadius.vertical(
//         bottom: Radius.circular(32),
//       ),
//     ),
//     child: Row(
//       children: [
//         // LEFT
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Schedule",
//                 style: GoogleFonts.nunito(
//                   fontSize: 26,
//                   fontWeight: FontWeight.w900,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 "You are almost done!",
//                 style: GoogleFonts.nunito(
//                   color: Colors.black54,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 "$completed / $total tasks completed",
//                 style: GoogleFonts.nunito(
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ],
//           ),
//         ),
//
//         // RIGHT (CIRCULAR PROGRESS)
//         SizedBox(
//           height: 90,
//           width: 90,
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               CircularProgressIndicator(
//                 value: percent,
//                 strokeWidth: 8,
//                 backgroundColor: Colors.white,
//                 color: kTeal,
//               ),
//               Text(
//                 "${(percent * 100).round()}%",
//                 style: GoogleFonts.nunito(
//                   fontWeight: FontWeight.w900,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }