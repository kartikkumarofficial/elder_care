import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pedometer/pedometer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CaregiverDashboardController extends GetxController {
  final supabase = Supabase.instance.client;
  // ----------------------------- VITAL HISTORY FOR CHARTS -----------------------------
  RxList<double> heartRateHistory = <double>[80, 82, 81, 83, 85].obs;
  RxList<double> oxygenHistory = <double>[95, 96, 97, 96, 98].obs;


  // ----------------------------- STATE FLAGS -----------------------------
  final RxBool isMapReady = false.obs;
  final RxBool isLoading = false.obs;

  // ----------------------------- RECEIVER DATA ---------------------------
  final RxString receiverId = "".obs;
  final RxString name = "Loading...".obs;
  final RxString profileUrl = "".obs;

  // ----------------------------- LOCATION DATA ---------------------------
  final RxDouble lat = 0.0.obs;
  final RxDouble lng = 0.0.obs;
  final RxString lastLocationRefresh = "Loading...".obs;

  // ----------------------------- VITALS DATA -----------------------------
  final RxString heartRate = "--".obs;
  final RxString oxygen = "--".obs;
  final RxBool fallDetected = false.obs;

  // ----------------------------- DEVICE STATUS ---------------------------
  final RxBool fitbitConnected = false.obs;
  final RxInt battery = 82.obs;

  // ----------------------------- CONTROLLERS -----------------------------
  GoogleMapController? mapCtrl;
  RealtimeChannel? locationChannel;
  RealtimeChannel? vitalsChannel;

  @override
  void onInit() {
    super.onInit();
    loadReceiver();
  }

  @override
  void onClose() {
    locationChannel?.unsubscribe();
    vitalsChannel?.unsubscribe();
    super.onClose();
  }

  // ======================================================================
  // LOAD RECEIVER LINK
  // ======================================================================
  Future<void> loadReceiver() async {
    isLoading.value = true;

    final uid = supabase.auth.currentUser?.id;

    if (uid == null) {
      name.value = "User not logged in";
      isMapReady.value = true;
      isLoading.value = false;
      return;
    }

    try {

      final link = await supabase
          .from("care_links")
          .select("receiver_id")
          .eq("caregiver_id", uid)
          .maybeSingle();

      if (link == null || link["receiver_id"] == null) {
        name.value = "No Care Receiver Linked";
        receiverId.value = "";
        isMapReady.value = true;
        isLoading.value = false;
        return;
      }

      receiverId.value = link["receiver_id"];

      await fetchReceiverProfile();
      await fetchLatestLocation();
      await fetchLatestVitals();
      await fetchLatestSteps();

      subscribeToStepsRealtime();
      subscribeToLocationRealtime();
      subscribeToVitalsRealtime();
    } catch (e) {
      name.value = "Error loading receiver";
      print("ERROR: $e");
    }

    isMapReady.value = true;
    isLoading.value = false;
  }

  // ======================================================================
  // FETCH PROFILE
  // ======================================================================
  Future<void> fetchReceiverProfile() async {
    if (receiverId.value.isEmpty) return;

    final data = await supabase
        .from("users")
        .select("full_name, profile_image")
        .eq("id", receiverId.value)
        .maybeSingle();

    name.value = data?["full_name"] ?? "Unknown Receiver";
    profileUrl.value = data?["profile_image"] ?? "";
  }

  // ======================================================================
  // FETCH LATEST LOCATION
  // ======================================================================
  // Replace existing fetchLatestLocation() with this
  Future<void> fetchLatestLocation() async {
    if (receiverId.value.isEmpty) {
      print("fetchLatestLocation: receiverId empty");
      return;
    }

    try {
      // try primary table (your dashboard used user_locations)
      var row = await supabase
          .from('user_locations')
          .select('latitude, longitude, updated_at')
          .eq('user_id', receiverId.value)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      // fallback to 'locations' if nothing found (match your LocationService)
      if (row == null) {
        print('fetchLatestLocation: no row in user_locations, trying locations table');
        row = await supabase
            .from('locations')
            .select('latitude, longitude, updated_at')
            .eq('user_id', receiverId.value)
            .order('updated_at', ascending: false)
            .limit(1)
            .maybeSingle();
      }

      print('fetchLatestLocation raw: $row');

      if (row == null) {
        // no location: still allow UI to load
        isMapReady.value = true;
        return;
      }

      // Support multiple possible key names safely
      double? _lat;
      double? _lng;
      if (row['latitude'] != null && row['longitude'] != null) {
        _lat = (row['latitude'] as num).toDouble();
        _lng = (row['longitude'] as num).toDouble();
      } else if (row['lat'] != null && row['lng'] != null) {
        _lat = (row['lat'] as num).toDouble();
        _lng = (row['lng'] as num).toDouble();
      }

      if (_lat == null || _lng == null) {
        print('fetchLatestLocation: coordinates missing in row');
        isMapReady.value = true;
        return;
      }

      lat.value = _lat;
      lng.value = _lng;
      lastLocationRefresh.value = _formatTimeAgo(row['updated_at']?.toString() ?? DateTime.now().toIso8601String());

      // make UI visible
      isMapReady.value = true;

      // animate if map exists
      if (mapCtrl != null) {
        _animateMap();
      }
    } catch (e) {
      print('fetchLatestLocation error: $e');
      isMapReady.value = true; // let UI render even on error
    }
  }


  // ======================================================================
  // SUBSCRIBE REALTIME LOCATION
  // ======================================================================
  void subscribeToLocationRealtime() {
    if (receiverId.value.isEmpty) return;

    try { locationChannel?.unsubscribe(); } catch (_) {}

    // subscribe to both possible tables by creating two channels or pick the right one:
    final channelName = 'locations_${receiverId.value}';
    locationChannel = supabase.channel(channelName, opts: const RealtimeChannelConfig());

    locationChannel!
        .onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'user_locations', // keep user_locations if primary
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: receiverId.value,
      ),
      callback: (payload) {
        final newRow = payload.newRecord;
        print('realtime user_locations payload: $newRow');
        if (newRow == null) return;
        // reuse parsing logic from fetchLatestLocation
        final latVal = (newRow['latitude'] as num?) ?? (newRow['lat'] as num?);
        final lngVal = (newRow['longitude'] as num?) ?? (newRow['lng'] as num?);
        if (latVal != null && lngVal != null) {
          lat.value = latVal.toDouble();
          lng.value = lngVal.toDouble();
          lastLocationRefresh.value = _formatTimeAgo(newRow['updated_at']?.toString() ?? DateTime.now().toIso8601String());
          if (!isMapReady.value) isMapReady.value = true;
          _animateMap();
        }
      },
    ).subscribe();

    // Optionally create a second subscription for the 'locations' table (if you actually use that).
  }

  Future<void> fetchDeviceStatus() async {
    print("fetchDeviceStatus: fetching for ${receiverId.value}");

    final row = await supabase
        .from("device_status")
        .select()
        .eq("user_id", receiverId.value)
        .maybeSingle();

    print("Device Status fetched: $row");

    if (row == null) {
      print("❌ No device status row found.");
      return;
    }

    battery.value = row["battery_level"] ?? 0;
    fitbitConnected.value = row["fitbit_connected"] ?? false;
  }



  // ======================================================================
  // FETCH VITALS
  // ======================================================================
  Future<void> fetchLatestVitals() async {
    if (receiverId.value.isEmpty) {
      print("fetchLatestVitals: NO RECEIVER ID");
      return;
    }

    print("fetchLatestVitals: fetching vitals for ${receiverId.value}");

    final rows = await supabase
        .from("health_vitals")
        .select()
        .eq("user_id", receiverId.value)
        .order("timestamp", ascending: false);

    print("Vitals fetched: $rows");

    if (rows.isEmpty) {
      print("❌ No vitals found for this receiver");
      return;
    }

    Map<String, dynamic> latest = {};

    for (var row in rows) {
      if (!latest.containsKey(row["type"])) latest[row["type"]] = row;
    }

    print("Latest vitals map: $latest");

    // HEART
    if (latest["heart_rate"]?["value"] != null) {
      double hr = (latest["heart_rate"]["value"] as num).toDouble();
      heartRate.value = hr.toString();
    } else {
      print("❌ No heart_rate in latest records");
    }

    // OXYGEN
    if (latest["oxygen"]?["value"] != null) {
      double oxy = (latest["oxygen"]["value"] as num).toDouble();
      oxygen.value = oxy.toString();
    } else {
      print("❌ No oxygen in latest records");
    }

    // FALL
    if (latest["fall_detected"]?["value"] != null) {
      fallDetected.value = latest["fall_detected"]["value"] == 1;
    } else {
      print("❌ No fall_detected record");
    }
  }



  // ======================================================================
  // SUBSCRIBE REALTIME VITALS
  // ======================================================================
  void subscribeToVitalsRealtime() {
    if (receiverId.value.isEmpty) return;

    vitalsChannel?.unsubscribe();

    vitalsChannel = supabase.channel("vitals_${receiverId.value}");

    vitalsChannel!
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: "public",
      table: "health_vitals",
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: "user_id",
        value: receiverId.value,
      ),
      callback: (payload) {
        final row = payload.newRecord;
        if (row == null) return;

        switch (row["type"]) {
          case "heart_rate":
            double hr = (row["value"] as num).toDouble();
            heartRate.value = hr.toString();

            heartRateHistory.add(hr);
            if (heartRateHistory.length > 20) heartRateHistory.removeAt(0);
            break;

          case "oxygen":
            double oxy = (row["value"] as num).toDouble();
            oxygen.value = oxy.toString();

            oxygenHistory.add(oxy);
            if (oxygenHistory.length > 20) oxygenHistory.removeAt(0);
            break;

          case "fall_detected":
            fallDetected.value = row["value"] == 1;
            break;
        }
      },
    ).subscribe();
  }

  // ======================================================================
  // MAP HANDLING
  // ======================================================================
  void onMapCreated(GoogleMapController c) {
    mapCtrl = c;
    isMapReady.value = true;

    // Move camera if valid
    if (lat.value != 0.0 && lng.value != 0.0) {
      _moveCamera();
    }
  }

  void _moveCamera() {
    if (mapCtrl == null) return;
    if (lat.value == 0.0 || lng.value == 0.0) return;

    mapCtrl!.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(lat.value, lng.value),
        15,
      ),
    );
  }

  // ======================================================================
  // MANUAL REFRESH
  // ======================================================================
  RxBool isRefreshing = false.obs;

  Future<void> refreshData() async {
    print("🔄 Refresh tapped at: ${DateTime.now()}");
    isRefreshing.value = true;

    // Simulate API call / Fitbit fetch
    await Future.delayed(const Duration(seconds: 1));

    
    await fetchLatestLocation();
    await fetchLatestVitals();
    await fetchDeviceStatus();

    isRefreshing.value = false;
    print("✅ Refresh completed!");
  }

  // ======================================================================
  // UTILS
  // ======================================================================
  String _formatTimeAgo(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      final diff = DateTime.now().difference(dt);

      if (diff.inMinutes < 1) return "Just now";
      if (diff.inHours < 1) return "${diff.inMinutes}m ago";
      if (diff.inDays < 1) return "${diff.inHours}h ago";
      return "${diff.inDays}d ago";
    } catch (e) {
      return timestamp;
    }
  }
  void _animateMap() {
    if (mapCtrl == null) return;       // map not created yet
    if (lat.value == 0.0 && lng.value == 0.0) return;  // invalid location

    try {
      mapCtrl!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(lat.value, lng.value),
          15,
        ),
      );
    } catch (e) {
      print("ANIMATE ERROR: $e");
    }
  }
  final batery = Battery();

  Future<void> sendBatteryToSupabase(String userId) async {
    final level = await batery.batteryLevel;

    await Supabase.instance.client
        .from("device_status")
        .upsert({
      "user_id": userId,
      "battery_level": level,
      "updated_at": DateTime.now().toIso8601String(),
    });
  }


  //pedometer - for steps


// ====================== STEPS ======================
  RxString steps = "--".obs;



  Future<void> fetchLatestSteps() async {
    if (receiverId.value.isEmpty) return;

    final row = await supabase
        .from("steps_data")
        .select("steps")
        .eq("user_id", receiverId.value)
        .order("timestamp", ascending: false)
        .limit(1)
        .maybeSingle();

    if (row != null) {
      steps.value = row["steps"].toString();
    }
  }
  void subscribeToStepsRealtime() {
    if (receiverId.value.isEmpty) return;

    final channel = supabase.channel("steps_${receiverId.value}");

    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: "public",
      table: "steps_data",
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: "user_id",
        value: receiverId.value,
      ),
      callback: (payload) {
        final newSteps = payload.newRecord["steps"];
        steps.value = newSteps.toString();
      },
    ).subscribe();
  }




}
