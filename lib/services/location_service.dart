import 'package:location/location.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationService {
  final Location _location = Location();
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Requests location service and permissions from the user.
  /// Returns true if permission is granted, false otherwise.
  Future<bool> requestPermissions() async {
    print('[LocationService] Requesting permissions...');
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        print('[LocationService] Location service not enabled by user.');
        return false;
      }
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
    }
    if (permissionGranted != PermissionStatus.granted) {
      print('[LocationService] Location permission not granted.');
      return false;
    }
    print('[LocationService] Permissions granted.');
    return true;
  }

  /// Fetches the current location and updates it in the 'locations' table.
  Future<void> updateLocationInSupabase() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      print('[LocationService] Cannot update location, user is not logged in.');
      return;
    }

    try {
      print('[LocationService] Getting current location...');
      final locationData = await _location.getLocation();
      print('[LocationService] Location fetched: Lat: ${locationData.latitude}, Lon: ${locationData.longitude}');

      await _supabase
          .from('locations') // Using 'locations' table
          .upsert({
        'user_id': user.id, // This is the primary key
        'latitude': locationData.latitude,
        'longitude': locationData.longitude,
        'updated_at': DateTime.now().toIso8601String(),
      });
      print('[LocationService] Location successfully updated in Supabase.');
    } catch (e) {
      print('[LocationService] Error updating location in Supabase: $e');
    }
  }

  /// Fetches the latest location for a given user ID from the 'locations' table.
  Future<Map<String, dynamic>?> getLocationOfLinkedUser(String linkedUserId) async {
    try {
      print('[LocationService] Fetching location for linked user ID: $linkedUserId');
      final response = await _supabase
          .from('locations')
          .select()
          .eq('user_id', linkedUserId)
          .single();

      print('[LocationService] Supabase response for linked user: $response');
      return response;
    } catch (e) {
      print('[LocationService] Error fetching linked user location: $e');
      return null;
    }
  }
}
