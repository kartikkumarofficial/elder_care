import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';

class LocationController extends GetxController {
  final String linkedUserId;
  LocationController({required this.linkedUserId});

  final LocationService _locationService = LocationService();
  final MapController mapController = MapController();

  // Flag to track if the map widget is ready.
  bool _isMapReady = false;

  // Observables for UI state
  final Rx<LatLng?> receiverLocation = Rx<LatLng?>(null);
  final Rx<DateTime?> lastUpdatedAt = Rx<DateTime?>(null);
  final isLoading = true.obs;
  final RxString timeAgo = ''.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    fetchLocation();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateTimeAgo();
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  /// This method is called by the UI when the map is initialized.
  void onMapReady() {
    _isMapReady = true;
    // If location data is already available, move the map to it now.
    if (receiverLocation.value != null) {
      mapController.move(receiverLocation.value!, 15.0);
    }
  }

  void _updateTimeAgo() {
    if (lastUpdatedAt.value == null) {
      timeAgo.value = '';
      return;
    }
    final difference = DateTime.now().difference(lastUpdatedAt.value!);
    if (difference.inMinutes < 1) {
      timeAgo.value = 'Updated just now';
    } else if (difference.inMinutes < 60) {
      timeAgo.value = 'Updated ${difference.inMinutes} minute(s) ago';
    } else if (difference.inHours < 24) {
      timeAgo.value = 'Updated ${difference.inHours} hour(s) ago';
    } else {
      timeAgo.value = 'Updated ${difference.inDays} day(s) ago';
    }
  }

  Future<void> fetchLocation({bool isRefresh = false}) async {
    try {
      // Only show full-screen loader on initial fetch
      if (receiverLocation.value == null) {
        isLoading.value = true;
      }
      if (isRefresh) {
        Get.snackbar('Refreshing...', 'Fetching the latest location.', snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 2));
      }
      final data = await _locationService.getLocationOfLinkedUser(linkedUserId);

      if (data != null && data['latitude'] != null && data['longitude'] != null) {
        receiverLocation.value = LatLng(data['latitude'], data['longitude']);

        if (data['updated_at'] != null) {
          lastUpdatedAt.value = DateTime.tryParse(data['updated_at']);
          _updateTimeAgo();
        }

        // Instead of moving the map here, we now check the _isMapReady flag.
        // If the map is already ready, we move it. If not, the onMapReady
        // callback will handle moving it once it's ready.
        if (_isMapReady) {
          mapController.move(receiverLocation.value!, 15.0);
        }
      } else if (isRefresh) {
        // Only show a snackbar if a manual refresh fails.
        Get.snackbar(
          'Location Not Found',
          'Could not retrieve location. The user may not be sharing it.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while fetching the location.', snackPosition: SnackPosition.BOTTOM);
      print('[LocationController] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
