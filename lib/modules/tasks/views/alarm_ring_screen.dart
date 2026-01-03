import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AlarmRingScreen extends StatefulWidget {
  final String title;
  const AlarmRingScreen({super.key, required this.title});

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> {
  late Timer _vibrationTimer;

  @override
  void initState() {
    super.initState();

    // keep screen awake
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // vibrate loop
    _vibrationTimer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => HapticFeedback.heavyImpact(),
    );
  }

  @override
  void dispose() {
    _vibrationTimer.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.alarm, color: Colors.white, size: 96),
            const SizedBox(height: 20),
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onHorizontalDragEnd: (_) => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(24),
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Center(
                  child: Text(
                    'Slide to stop',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
