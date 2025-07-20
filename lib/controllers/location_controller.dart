import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';

class LocationController extends GetxController {
  final String linkedUserId;
  LocationController({required this.linkedUserId});

  final LocationService _locationService = LocationService();
  final MapController mapController = MapController();

  final Rx<LatLng?> receiverLocation = Rx<LatLng?>(null);
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLocation();
  }

  Future<void> fetchLocation({bool isRefresh = false}) async {
    try {
      isLoading.value = true;
      if (isRefresh) {
        Get.snackbar('Refreshing...', 'Fetching the latest location.', snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 2));
      }
      final data = await _locationService.getLocationOfLinkedUser(linkedUserId);

      if (data != null && data['latitude'] != null && data['longitude'] != null) {
        receiverLocation.value = LatLng(data['latitude'], data['longitude']);
        await Future.delayed(const Duration(milliseconds: 500));
        mapController.move(receiverLocation.value!, 15.0);
      } else {
        Get.snackbar(
          'Location Not Found',
          'Could not retrieve the location. The user may not be sharing it.',
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
