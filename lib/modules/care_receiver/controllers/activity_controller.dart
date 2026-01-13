import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ActivityController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  // CONFIG
  static const Duration onlineThreshold = Duration(minutes: 3);
  static const Duration watcherInterval = Duration(seconds: 30);

  // STATE
  final RxBool isOnline = false.obs;
  final RxString lastSeenText = ''.obs;

  DateTime? _lastActivityAt;
  DateTime? get lastActivityAt => _lastActivityAt;
  Timer? _watcher;

  @override
  void onInit() {
    super.onInit();
    _startWatcher();
  }

  @override
  void onClose() {
    _watcher?.cancel();
    super.onClose();
  }

  // 🔥 CALL THIS ON ANY ACTIVITY
  Future<void> markActive({bool syncToServer = true}) async {
    final now = DateTime.now();

    _lastActivityAt = now;
    isOnline.value = true;
    lastSeenText.value = 'Online';

    if (syncToServer) {
      await _syncToSupabase(now);
    }
  }

  // CAREGIVER SIDE (fetch receiver activity)
  Future<void> hydrateFromServer(String receiverId) async {
    final res = await supabase
        .from('user_locations')
        .select('last_activity_at')
        .eq('user_id', receiverId)
        .maybeSingle();

    if (res == null) {
      isOnline.value = false;
      lastSeenText.value = 'Offline';
      return;
    }

    final last =
    DateTime.parse(res['last_activity_at'] + 'Z').toLocal();

    _lastActivityAt = last;
    _recompute();
  }

  // INTERNAL
  void _startWatcher() {
    _watcher = Timer.periodic(watcherInterval, (_) => _recompute());
  }

  void _recompute() {
    if (_lastActivityAt == null) {
      isOnline.value = false;
      lastSeenText.value = 'Inactive';
      return;
    }

    final diff = DateTime.now().difference(_lastActivityAt!);

    if (diff <= onlineThreshold) {
      isOnline.value = true;
      lastSeenText.value = 'Connected';
    } else {
      isOnline.value = false;

      if (diff.inMinutes < 60) {
        lastSeenText.value = 'Last seen ${diff.inMinutes} min ago';
      } else if (diff.inHours < 24) {
        lastSeenText.value = 'Last seen ${diff.inHours} hr ago';
      } else {
        lastSeenText.value = 'Last seen ${diff.inDays} days ago';
      }
    }
  }

  Future<void> _syncToSupabase(DateTime at) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('user_locations').upsert({
      'user_id': user.id,
      'last_activity_at': at.toUtc().toIso8601String(),
    }, onConflict: 'user_id');
  }
}
