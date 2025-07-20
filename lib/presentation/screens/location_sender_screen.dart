import 'dart:async';
import 'package:elder_care/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocationSenderScreen extends StatefulWidget {
  const LocationSenderScreen({super.key});

  @override
  State<LocationSenderScreen> createState() => _LocationSenderScreenState();
}

class _LocationSenderScreenState extends State<LocationSenderScreen> {
  final LocationService _locationService = LocationService();
  Timer? _locationUpdateTimer;
  bool _isSharing = false;
  String _statusMessage = "Press the button to start sharing your location.";

  @override
  void dispose() {
    _locationUpdateTimer?.cancel(); // Stop the timer when the screen is closed
    super.dispose();
  }

  void _toggleLocationSharing() async {
    if (_isSharing) {
      // Stop sharing
      _locationUpdateTimer?.cancel();
      setState(() {
        _isSharing = false;
        _statusMessage = "Location sharing paused. Press the button to resume.";
      });
    } else {
      // Start sharing
      bool permissionsGranted = await _locationService.requestPermissions();
      if (permissionsGranted) {
        setState(() {
          _isSharing = true;
          _statusMessage = "Sharing location... Your caregiver can now see you.";
        });
        // Send location immediately
        await _locationService.updateLocationInSupabase();
        // Then update every 1 minute
        _locationUpdateTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
          await _locationService.updateLocationInSupabase();
        });
      } else {
        Get.snackbar(
          'Permission Denied',
          'Location permissions are required to share your location.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share My Location'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isSharing ? Icons.location_on : Icons.location_off,
                size: 100,
                color: _isSharing ? Colors.greenAccent : Colors.grey,
              ),
              const SizedBox(height: 32),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _toggleLocationSharing,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSharing ? Colors.redAccent : Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: Text(_isSharing ? 'Stop Sharing' : 'Start Sharing'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
