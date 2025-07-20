import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationService extends GetxService {
  final GeolocatorPlatform geolocator = GeolocatorPlatform.instance;

  Future<Position?> getCurrentLocation() async {
    LocationPermission permission = await geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    return await geolocator.getCurrentPosition();
  }
}


void updateLocationToSupabase() async {
  final pos = await LocationService().getCurrentLocation();
  if (pos == null) return;

  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return;

  await Supabase.instance.client.from('locations').upsert({
    'user_id': userId,
    'latitude': pos.latitude,
    'longitude': pos.longitude,
    'updated_at': DateTime.now().toUtc().toIso8601String(),
  });
}


Future<Map<String, dynamic>?> fetchReceiverLocation(String receiverId) async {
  final res = await Supabase.instance.client
      .from('locations')
      .select()
      .eq('user_id', receiverId)
      .order('updated_at', ascending: false)
      .limit(1)
      .maybeSingle();

  return res;
}
