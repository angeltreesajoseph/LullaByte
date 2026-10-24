import 'package:dio/dio.dart';
import 'dart:async';

/// Brief session-only reuse, never persisted to disk. Writes and logout invalidate it.
class _CareSnapshots {
  static int generation = 0;
  static final entries = <String, ({DateTime at, Response response})>{};
  static final pending = <String, Completer<Response?>>{};
  static const lifetime = Duration(seconds: 10);
  static void clear() {
    generation++;
    entries.clear();
    for (final request in pending.values) {
      if (!request.isCompleted) request.complete(null);
    }
    pending.clear();
  }

  static dynamic copy(dynamic value) {
    if (value is Map)
      return value.map<String, dynamic>(
        (k, v) => MapEntry(k.toString(), copy(v)),
      );
    if (value is List) return value.map(copy).toList();
    return value;
  }

  static Response clone(Response source, RequestOptions request) => Response(
    requestOptions: request,
    data: copy(source.data),
    statusCode: source.statusCode,
    headers: source.headers,
    statusMessage: source.statusMessage,
  );
  static String key(RequestOptions r) =>
      '${r.baseUrl}|${r.headers['Authorization']}|${r.path}';
  static bool eligible(RequestOptions r) =>
      r.method == 'GET' &&
      r.queryParameters.isEmpty &&
      (r.path == '/babies' || RegExp(r'^/babies/[^/]+$').hasMatch(r.path));
  static void finish(RequestOptions request, Response? response) {
    final owner = request.extra['_snapshot_pending'];
    if (owner is! Completer<Response?>) return;
    final key = request.extra['_snapshot_key'] as String;
    if (identical(pending[key], owner)) pending.remove(key);
    if (!owner.isCompleted) owner.complete(response);
  }
}

/// Versions are learned from server reads, never guessed from local entries.
class CareRevisions {
  static void invalidateSnapshots() => _CareSnapshots.clear();
  static final Map<String, Map<String, String>> _versions = {};
  static void clear() {
    _versions.clear();
    _CareSnapshots.clear();
  }

  static void remember(Map baby) {
    final id = baby['id'];
    final revisions = baby['tracker_revisions'];
    if (id is String && revisions is Map) {
      _versions[id] = revisions.map(
        (k, v) => MapEntry(k.toString(), v.toString()),
      );
    }
  }
}

Dio careDio([BaseOptions? options]) {
  final api = Dio(options);
  api.options.connectTimeout ??= const Duration(seconds: 20);
  api.options.receiveTimeout ??= const Duration(seconds: 30);
  final tracker = RegExp(r'^/babies/([^/]+)/trackers/([^/]+)$');
  api.interceptors.add(
    InterceptorsWrapper(
      onRequest: (request, handler) async {
        if (request.method != 'GET' &&
            !request.path.endsWith('/assistant') &&
            (request.path.startsWith('/babies') ||
                request.path.startsWith('/sharing/') &&
                    !request.path.contains('/alerts') &&
                    !request.path.endsWith('/device'))) {
          _CareSnapshots.clear();
        }
        if (_CareSnapshots.eligible(request)) {
          final key = _CareSnapshots.key(request);
          if (request.extra['fresh'] == true) _CareSnapshots.clear();
          final cached = _CareSnapshots.entries[key];
          if (cached != null &&
              DateTime.now().difference(cached.at) < _CareSnapshots.lifetime) {
            handler.resolve(_CareSnapshots.clone(cached.response, request));
            return;
          }
          final inflight = _CareSnapshots.pending[key];
          if (inflight != null) {
            final version = _CareSnapshots.generation;
            final response = await inflight.future;
            if (response != null && version == _CareSnapshots.generation) {
              handler.resolve(_CareSnapshots.clone(response, request));
              return;
            }
          }
          final owner = Completer<Response?>();
          _CareSnapshots.pending[key] = owner;
          request.extra.addAll({
            '_snapshot_pending': owner,
            '_snapshot_key': key,
            '_snapshot_generation': _CareSnapshots.generation,
          });
        }
        final match = tracker.firstMatch(request.path);
        if (request.method == 'PUT' && match != null) {
          final revision = CareRevisions._versions[match[1]]?[match[2]];
          if (revision != null) request.headers['X-Care-Revision'] = revision;
        }
        handler.next(request);
      },
      onResponse: (response, handler) {
        final request = response.requestOptions;
        if (request.method != 'GET' &&
            !request.path.endsWith('/assistant') &&
            (request.path.startsWith('/babies') ||
                request.path.startsWith('/sharing/') &&
                    !request.path.contains('/alerts') &&
                    !request.path.endsWith('/device')))
          _CareSnapshots.clear();
        if (_CareSnapshots.eligible(request) &&
            response.statusCode == 200 &&
            request.extra['_snapshot_generation'] ==
                _CareSnapshots.generation) {
          // Store an isolated copy so an open editor cannot change another screen's snapshot.
          final saved = _CareSnapshots.clone(response, request);
          if (_CareSnapshots.entries.length > 8) _CareSnapshots.entries.clear();
          _CareSnapshots.entries[_CareSnapshots.key(request)] = (
            at: DateTime.now(),
            response: saved,
          );
          final payload = saved.data is Map ? saved.data['data'] : null;
          if (request.path == '/babies' && payload is List) {
            for (final baby in payload.whereType<Map>().take(8)) {
              if (baby['id'] is! String) continue;
              final detail = RequestOptions(
                baseUrl: request.baseUrl,
                path: '/babies/${baby['id']}',
                headers: request.headers,
              );
              _CareSnapshots.entries[_CareSnapshots.key(detail)] = (
                at: DateTime.now(),
                response: Response(
                  requestOptions: detail,
                  statusCode: 200,
                  data: {'data': baby},
                ),
              );
            }
          }
          _CareSnapshots.finish(request, saved);
        } else {
          _CareSnapshots.finish(request, null);
        }
        final data = response.data is Map ? response.data['data'] : null;
        if (request.method == 'GET' &&
            (!_CareSnapshots.eligible(request) ||
                request.extra['_snapshot_generation'] ==
                    _CareSnapshots.generation)) {
          if (data is List) {
            for (final baby in data.whereType<Map>()) {
              CareRevisions.remember(baby);
            }
          } else if (data is Map && data.containsKey('tracker_revisions')) {
            CareRevisions.remember(data);
          }
        }
        final match = tracker.firstMatch(response.requestOptions.path);
        final revision = response.headers.value('x-care-revision');
        if (match != null && revision != null) {
          (CareRevisions._versions[match[1]!] ??= {})[match[2]!] = revision;
        }
        handler.next(response);
      },
      onError: (error, handler) {
        _CareSnapshots.finish(error.requestOptions, null);
        handler.next(error);
      },
    ),
  );
  return api;
}
