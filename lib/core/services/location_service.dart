// core/services/location_service.dart

import 'package:location/location.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationService {
  final Location _location = Location();
  final SupabaseClient _supabase = Supabase.instance.client;

  /* -------------------------------------------------------------------------- */
  /*                          1) Permission + Service                           */
  /* -------------------------------------------------------------------------- */

  /// Requests location service + permission on DEVICE (receiver phone).
  Future<bool> requestPermissions() async {
    print('[LocationService] Requesting permissions...');

    // Check if location service is ON
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        print('[LocationService] User declined enabling location services.');
        return false;
      }
    }

    // Check and request permission
    PermissionStatus permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
    }

    if (permission != PermissionStatus.granted) {
      print('[LocationService] Location permission not granted.');
      return false;
    }

    print('[LocationService] Permissions granted.');
    return true;
  }

  /* -------------------------------------------------------------------------- */
  /*                     2) Update Receiver Location to Supabase                */
  /* -------------------------------------------------------------------------- */

  /// Called on RECEIVER SIDE every X seconds or when using background tracking.
  Future<void> updateLocationInSupabase() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      print('[LocationService] Cannot update location, user not logged in.');
      return;
    }

    try {
      print('[LocationService] Getting current location...');
      final loc = await _location.getLocation();
      print('[LocationService] Location fetched: lat=${loc.latitude}, lng=${loc.longitude}');

      await _supabase.from('locations').upsert({
        'user_id': user.id,
        'latitude': loc.latitude,
        'longitude': loc.longitude,
        'updated_at': DateTime.now().toIso8601String(),
      });

      print('[LocationService] Location updated successfully in Supabase.');
    } catch (e) {
      print('[LocationService] Error updating location: $e');
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                       3) Fetch Receiver Location (Caregiver Side)          */
  /* -------------------------------------------------------------------------- */

  /// Fetches the MOST RECENT location of the linked user.
  Future<Map<String, dynamic>?> getLocationOfLinkedUser(String linkedUserId) async {
    try {
      print('[LocationService] Fetching latest location for $linkedUserId...');

      final response = await _supabase
          .from('locations')
          .select()
          .eq('user_id', linkedUserId)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      print('[LocationService] Fetched location: $response');
      return response;
    } catch (e) {
      print('[LocationService] Error fetching linked user location: $e');
      return null;
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                      4) Fetch Saved Geofence from Supabase                 */
  /* -------------------------------------------------------------------------- */

  Future<Map<String, dynamic>?> fetchGeofence(String receiverId) async {
    try {
      print('[LocationService] Fetching geofence for receiver $receiverId');

      final res = await _supabase
          .from('geofences')
          .select()
          .eq('receiver_id', receiverId)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      print('[LocationService] Geofence result: $res');
      return res;
    } catch (e) {
      print('[LocationService] Error fetching geofence: $e');
      return null;
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                        5) Save / Update Geofence                           */
  /* -------------------------------------------------------------------------- */

  Future<bool> saveGeofence(
      String receiverId, double lat, double lng, int radius) async {
    try {
      print('[LocationService] Saving geofence...');

      final existing = await fetchGeofence(receiverId);

      if (existing != null) {
        // update
        await _supabase
            .from('geofences')
            .update({
          'latitude': lat,
          'longitude': lng,
          'radius': radius,
          'updated_at': DateTime.now().toIso8601String(),
        })
            .eq('id', existing['id']);
      } else {
        // insert new record
        await _supabase.from('geofences').insert({
          'receiver_id': receiverId,
          'latitude': lat,
          'longitude': lng,
          'radius': radius,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      print('[LocationService] Geofence saved.');
      return true;
    } catch (e) {
      print('[LocationService] Error saving geofence: $e');
      return false;
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                           6) Remove Geofence                               */
  /* -------------------------------------------------------------------------- */

  Future<bool> removeGeofence(String receiverId) async {
    try {
      print('[LocationService] Removing geofence...');
      await _supabase.from('geofences').delete().eq('receiver_id', receiverId);
      print('[LocationService] Geofence removed.');
      return true;
    } catch (e) {
      print('[LocationService] Error removing geofence: $e');
      return false;
    }
  }
}
