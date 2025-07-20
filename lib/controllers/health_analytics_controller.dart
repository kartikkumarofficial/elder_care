// import 'package:get/get.dart';
// import '../services/health_data_service.dart';
//
// class HealthAnalyticsController extends GetxController {
//   final String userId;
//   HealthAnalyticsController({required this.userId});
//
//   final HealthDataService _healthDataService = HealthDataService();
//
//   final isLoading = true.obs;
//   final RxMap<String, Map<String, dynamic>?> latestVitals = <String, Map<String, dynamic>?>{}.obs;
//
//   final List<String> vitalTypes = ['Heart Rate', 'Blood Pressure', 'Sugar'];
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchLatestVitals();
//   }
//
//   /// Fetches the latest reading for all vital types sequentially.
//   Future<void> fetchLatestVitals() async {
//     isLoading.value = true;
//     try {
//       // **THE FIX**: Fetch each vital one by one to prevent overloading the device.
//       final heartRateData = await _healthDataService.getLatestVital('Heart Rate', userId);
//       latestVitals['Heart Rate'] = heartRateData;
//
//       final bpData = await _healthDataService.getLatestVital('Blood Pressure', userId);
//       latestVitals['Blood Pressure'] = bpData;
//
//       final sugarData = await _healthDataService.getLatestVital('Sugar', userId);
//       latestVitals['Sugar'] = sugarData;
//
//     } catch (e) {
//       print('[HealthAnalyticsController] Error fetching latest vitals: $e');
//       Get.snackbar("Error", "Could not fetch health data.");
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }
