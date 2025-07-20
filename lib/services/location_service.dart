// services/location_service.dart
// import 'package:location/location.dart';
import 'package:location/location.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationService {
  final Location _location = Location();
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> requestPermissions() async {
    bool _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) return;
    }

    PermissionStatus _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
    }
    if (_permissionGranted != PermissionStatus.granted) return;
  }

  Future<void> updateLocationInSupabase() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final locationData = await _location.getLocation();

    await supabase
        .from('user_locations')
        .upsert({
      'user_id': user.id,
      'latitude': locationData.latitude,
      'longitude': locationData.longitude,
      'updated_at': DateTime.now().toIso8601String(),
    },
        onConflict: 'user_id'); // Ensures update if exists
  }

  Future<Map<String, dynamic>?> getLocationOfLinkedUser(String linkedUserId) async {
    final response = await supabase
        .from('user_locations')
        .select()
        .eq('user_id', linkedUserId)
        .single();

    return response;
  }
}
