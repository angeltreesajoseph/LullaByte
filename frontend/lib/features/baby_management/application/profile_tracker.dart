import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import 'baby_profile_store.dart';

/// Each tracker reads and writes only the active owner's baby ID.
mixin ProfileTracker<T extends StatefulWidget> on State<T> {
  String get trackerKind;
  List<Map<String, dynamic>> encodeEntries();
  void decodeEntries(List<Map<String, dynamic>> entries);
  bool trackerReady = false;
  String? _loadedBabyId;
  Future<void> _writes = Future.value();

  Future<Dio> _client() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Please sign in.');
    return Dio(
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
    final id = BabyProfileStore.id;
    _loadedBabyId = id;
    trackerReady = false;
    if (mounted) setState(() => decodeEntries([]));
    if (id == null) return;
    try {
      final client = await _client();
      final result = await client.get<Map<String, dynamic>>('/babies/$id');
      if (!mounted || BabyProfileStore.id != id) return;
      final data = result.data!['data'] as Map;
      BabyProfileStore.data = Map<String, dynamic>.from(data);
      final records =
          (data['tracker_data'] as Map?)?[trackerKind] as List? ?? [];
      setState(() {
        decodeEntries(
          records.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
        );
        trackerReady = true;
      });
    } catch (_) {
      if (mounted && BabyProfileStore.id == id) {
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
