import '../../../core/network/care_dio.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import 'baby_profile_store.dart';

/// Each tracker reads and writes only the active owner's baby ID.
mixin ProfileTracker<T extends StatefulWidget> on State<T> {
  String get trackerKind;

  /// Append-only server endpoints can start from an authorized session snapshot.
  /// Whole-list editors still wait for a fresh revision by default.
  bool get allowSnapshotReady => false;
  List<Map<String, dynamic>> encodeEntries();
  void decodeEntries(List<Map<String, dynamic>> entries);
  bool trackerReady = false;
  String? _loadedBabyId;
  Future<void> _writes = Future.value();
  int _readVersion = 0;

  Future<Dio> createTrackerClient() => _client();

  /// A newer server mutation must not be overwritten by an older in-flight GET.
  void acceptServerTrackerMutation() {
    _readVersion++;
    trackerReady = true;
  }

  Future<Dio> _client() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Please sign in.');
    return careDio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        headers: {'Authorization': 'Bearer ${await user.getIdToken()}'},
      ),
    );
  }

  void startTracker() {
    BabyProfileStore.changes.addListener(_profileChanged);
    _profileChanged();
  }

  void stopTracker() =>
      BabyProfileStore.changes.removeListener(_profileChanged);

  void _profileChanged() {
    if (_loadedBabyId == BabyProfileStore.id && trackerReady) return;
    _loadTracker();
  }

  Future<void> _loadTracker() async {
    final readVersion = ++_readVersion;
    final id = BabyProfileStore.id;
    _loadedBabyId = id;
    trackerReady = false;
    final snapshot = BabyProfileStore.snapshotFor(id);
    trackerReady =
        allowSnapshotReady &&
        snapshot != null &&
        const {'owner', 'caregiver'}.contains(snapshot['access_role']);
    final records =
        (snapshot?['tracker_data'] as Map?)?[trackerKind] as List? ?? [];
    if (mounted)
      setState(
        () => decodeEntries(
          records.map((r) => Map<String, dynamic>.from(r as Map)).toList(),
        ),
      );
    if (id == null) return;
    try {
      final client = await createTrackerClient();
      final result = await client.get<Map<String, dynamic>>('/babies/$id');
      if (!mounted || BabyProfileStore.id != id || readVersion != _readVersion)
        return;
      final data = result.data!['data'] as Map;
      BabyProfileStore.rememberSnapshot(Map<String, dynamic>.from(data));
      final records =
          (data['tracker_data'] as Map?)?[trackerKind] as List? ?? [];
      setState(() {
        decodeEntries(
          records.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
        );
        trackerReady = true;
      });
    } catch (error) {
      if (mounted && BabyProfileStore.id == id && readVersion == _readVersion) {
        if (error is DioException &&
            const {401, 403, 404}.contains(error.response?.statusCode)) {
          setState(() {
            trackerReady = false;
            decodeEntries([]);
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not load records. Reopen this tracker to retry.',
            ),
          ),
        );
      }
    }
  }

  Future<void> saveTracker() async {
    final id = _loadedBabyId;
    if (!trackerReady || id == null || BabyProfileStore.id != id) return;
    final entries = encodeEntries();
    _writes = _writes
        .then((_) async {
          final client = await _client();
          await client.put('/babies/$id/trackers/$trackerKind', data: entries);
          if (BabyProfileStore.id == id) {
            BabyProfileStore.data = {
              ...BabyProfileStore.data,
              'tracker_data': {
                ...?BabyProfileStore.data['tracker_data']
                    as Map<String, dynamic>?,
                trackerKind: entries,
              },
            };
          }
        })
        .catchError((Object error) {
          if (mounted)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Records could not be saved. Please retry before leaving.',
                ),
              ),
            );
        });
    await _writes;
  }
}
