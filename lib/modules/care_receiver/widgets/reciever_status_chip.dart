import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/activity_controller.dart';
import '../controllers/carereceiver_dashboard_controller.dart';

class ReceiverStatusChips extends StatefulWidget {
  const ReceiverStatusChips({super.key});

  @override
  State<ReceiverStatusChips> createState() => _ReceiverStatusChipsState();
}

class _ReceiverStatusChipsState extends State<ReceiverStatusChips> {
  final ReceiverDashboardController controller = Get.find();
  final ActivityController activity = Get.find();
  final isSyncing = false.obs;
  final now = DateTime.now().obs;

  Timer? _ticker;

  @override
  void initState() {
    super.initState();

    ///  Update time every minute so "Xm ago" updates
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      now.value = DateTime.now();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = Get.width;
    final h = Get.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.03),
      child: Obx(() {
        final connected = activity.isOnline.value;
        final battery = controller.batteryLevel.value;
        final lastSync = activity.lastActivityAt;


        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F5F4),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              ///  DEVICE STATUS
              Expanded(
                child: _chip(
                  h,
                  icon: Icons.circle,
                  iconColor: connected ? Colors.green : Colors.red,
                  label: connected
                      ? "Connected"
                      : activity.lastSeenText.value,
                ),

              ),

              const SizedBox(width: 8),

              ///  BATTERY
              Expanded(
                child: _chip(
                  h,
                  icon: Icons.battery_full,
                  iconColor: battery <= 20 ? Colors.red : Colors.green,
                  label: "$battery%",
                ),
              ),

              const SizedBox(width: 8),

              /// ⟳ LAST SYNC
              Expanded(
                child: GestureDetector(
                  onTap: isSyncing.value
                      ? null
                      : () async {
                    isSyncing.value = true;

                    await controller.syncDeviceStatus();
                    await controller.refreshDeviceConnectionStatus();

                    debugPrint(
                        "⏱ Last sync updated: ${controller.lastDeviceSync}");

                    isSyncing.value = false;
                  },
                  child: _chip(
                    h,
                    icon: Icons.sync,
                    iconColor: Colors.blueGrey,
                    label: _adaptiveSyncLabel(
                      lastSync,
                      now.value,
                    ),
                    trailing: isSyncing.value
                        ? const SizedBox(
                      height: 14,
                      width: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(
                      Icons.refresh,
                      size: 14,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// CHIP UI
  Widget _chip(
      double h, {
        required IconData icon,
        required Color iconColor,
        required String label,
        Widget? trailing,
      }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight = constraints.maxWidth < 90;

        return Container(
          height: h * 0.04,
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isTight ? 8 : 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: isTight ? 10 : 12, color: iconColor),
              const SizedBox(width: 4),

              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              if (trailing != null && !isTight) ...[
                const SizedBox(width: 4),
                trailing,
              ],
            ],
          ),
        );
      },
    );
  }


  String _adaptiveSyncLabel(DateTime? last, DateTime now) {
    if (last == null) return "Sync";

    final diff = now.difference(last);

    if (diff.inMinutes < 1) return "Now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m";
    return "${diff.inHours}h";
  }
}
