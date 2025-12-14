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
  /// Update receiver location (receiver side)
  Future<void> updateLocationInSupabase() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final loc = await _location.getLocation();

    await _supabase.from('user_locations').upsert({
      'user_id': user.id,
      'latitude': loc.latitude,
      'longitude': loc.longitude,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id');

    print('[LocationService] Location updated: ${loc.latitude}, ${loc.longitude}');
  }


  /* -------------------------------------------------------------------------- */
  /*                       3) Fetch Receiver Location (Caregiver Side)          */
  /* -------------------------------------------------------------------------- */

  /// Fetches the MOST RECENT location of the linked user.
  /// Fetch receiver location (caregiver side)
  Future<Map<String, dynamic>?> getLocationOfLinkedUser(String linkedUserId) async {
    print('[LocationService] Fetching latest location for $linkedUserId...');

    final res = await _supabase
        .from('user_locations') // ✅ FIXED
        .select()
        .eq('user_id', linkedUserId)
        .maybeSingle();

    print('[LocationService] Fetched location: $res');
    return res;
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
  /* -------------------------------------------------------------------------- */
  /*                     🔹 Simple Helper: Get Current Location                  */
  /* -------------------------------------------------------------------------- */

  /// Returns the current device location WITHOUT updating Supabase.
  /// Used for SOS alert and other features that need raw coordinates.
  Future<LocationData?> getCurrentLocation() async {
    try {
      // Ensure permission
      final permissionGranted = await requestPermissions();
      if (!permissionGranted) return null;

      // Fetch location
      final loc = await _location.getLocation();
      print('[LocationService] Current location: ${loc.latitude}, ${loc.longitude}');
      return loc;
    } catch (e) {
      print('[LocationService] Error getting location: $e');
      return null;
    }
  }

}
