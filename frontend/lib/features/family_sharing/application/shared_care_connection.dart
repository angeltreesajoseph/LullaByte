import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/care_dio.dart';
import '../../baby_management/application/baby_profile_store.dart';
import '../../baby_management/data/baby_api.dart';

class PendingCareInvitation {
  static String? id;
  static String? parse(String input) {
    final match = RegExp(
      r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}',
    ).firstMatch(input.trim());
    return match?.group(0)?.toLowerCase();
  }
}

Future<Dio> sharedCareClient() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw StateError('Please sign in.');
  return careDio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Authorization': 'Bearer ${await user.getIdToken()}'},
    ),
  );
}

String sharedCareError(Object e) {
  if (e is StateError) return e.message.toString();
  if (e is DioException) {
    final body = e.response?.data;
    if (body is Map &&
        body['error'] is Map &&
        body['error']['message'] is String)
      return body['error']['message'] as String;
    if (e.response?.statusCode == 404)
      return 'Shared care is not deployed yet, or this profile is no longer shared with you.';
    return 'Connection unavailable. Your unsent message has been kept. Retry when connected.';
  }
  return 'Please sign in and retry.';
}

/// Refreshes read-only surfaces, not an open tracker form or an in-flight save.
class SharedCareLiveSync with WidgetsBindingObserver {
  static final instance = SharedCareLiveSync();
  Timer? _timer;
  String Function()? _path;
  String? _stamp;
  bool _running = false;
  final updatedAt = ValueNotifier<DateTime?>(null);
  void start(String Function() path) {
    _path = path;
    WidgetsBinding.instance.removeObserver(this);
    WidgetsBinding.instance.addObserver(this);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => refresh());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _stamp = null;
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _timer?.cancel();
    if (state == AppLifecycleState.resumed) {
      _timer = Timer.periodic(const Duration(seconds: 10), (_) => refresh());
      refresh();
    }
  }

  Future<void> refresh() async {
    final path = _path?.call();
    if (!{'/dashboard', '/trackers', '/baby/profile'}.contains(path) ||
        _running)
      return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final babyId = BabyProfileStore.id;
    if (uid == null || babyId == null) return;
    _running = true;
    try {
      final api = await sharedCareClient();
      final result = await api.get('/sharing/babies/$babyId/status');
      if (FirebaseAuth.instance.currentUser?.uid != uid ||
          BabyProfileStore.id != babyId)
        return;
      final data = result.data['data'];
      final stamp = '$uid/$babyId/${data['updated_at']}/${data['role']}';
      if (stamp != _stamp) {
        final baby = await api.get(
          '/babies/$babyId',
          options: Options(extra: {'fresh': true}),
        );
        if (FirebaseAuth.instance.currentUser?.uid != uid ||
            BabyProfileStore.id != babyId)
          return;
        final snapshot = Map<String, dynamic>.from(baby.data['data'] as Map);
        BabyProfileStore.babies = BabyProfileStore.babies
            .map((b) => b['id'] == babyId ? snapshot : b)
            .toList();
        BabyProfileStore.select(snapshot);
        _stamp = stamp;
      }
      updatedAt.value = DateTime.now();
    } on DioException catch (e) {
      if ({403, 404}.contains(e.response?.statusCode) &&
          FirebaseAuth.instance.currentUser?.uid == uid) {
        // A missing status route on an older server is not proof of revocation.
        try {
          final api = await sharedCareClient();
          final babies = await BabyApi(api).list();
          if (FirebaseAuth.instance.currentUser?.uid != uid) return;
          BabyProfileStore.babies = babies;
          if (BabyProfileStore.id == babyId &&
              !babies.any((b) => b['id'] == babyId)) {
            BabyProfileStore.select(babies.firstOrNull ?? {});
          }
        } catch (_) {
          /* Offline does not imply access removal. */
        }
      }
    } catch (_) {
      /* Saved records remain visible offline; no success claim. */
    } finally {
      _running = false;
    }
  }
}
