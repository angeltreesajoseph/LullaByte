import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lullabyte/core/network/care_dio.dart';
import 'package:lullabyte/features/baby_management/data/baby_api.dart';

void main() {
  setUp(CareRevisions.clear);
  tearDown(CareRevisions.clear);
  Dio client(
    String account,
    void Function(RequestOptions, RequestInterceptorHandler) reply,
  ) {
    final api = careDio(
      BaseOptions(
        baseUrl: 'https://example.test',
        headers: {'Authorization': account},
      ),
    );
    api.interceptors.add(InterceptorsWrapper(onRequest: reply));
    return api;
  }

  Map<String, dynamic> baby(int value) => {
    'id': 'one',
    'name': 'Anna',
    'tracker_data': {
      'feeding': [
        {'amount_ml': value},
      ],
    },
    'tracker_revisions': {'feeding': 'v$value'},
  };
  void respond(RequestOptions o, RequestInterceptorHandler h, dynamic data) =>
      h.resolve(
        Response(requestOptions: o, statusCode: 200, data: {'data': data}),
        true,
      );

  test(
    'list seeds detail snapshots without losing map types or sharing mutable data',
    () async {
      var calls = 0;
      final api = client('A', (o, h) {
        calls++;
        respond(o, h, [baby(10)]);
      });
      expect(await BabyApi(api).list(), hasLength(1));
      final detail = await api.get('/babies/one');
      detail.data['data']['tracker_data']['feeding'][0]['amount_ml'] = 99;
      final second = await api.get('/babies/one');
      expect(
        second.data['data']['tracker_data']['feeding'][0]['amount_ml'],
        10,
      );
      expect(calls, 1);
    },
  );
  test(
    'online assistant request does not evict unchanged baby snapshots',
    () async {
      var reads = 0;
      final api = client('A', (o, h) {
        if (o.method == 'GET') {
          reads++;
          respond(o, h, baby(10));
        } else {
          respond(o, h, {'answer': 'Hello'});
        }
      });
      await api.get('/babies/one');
      await api.post(
        '/babies/one/assistant',
        data: {'question': 'Hello', 'consent': true},
      );
      await api.get('/babies/one');
      expect(reads, 1);
    },
  );
  test(
    'duplicate requests across section clients share one network response',
    () async {
      var calls = 0;
      final gate = Completer<void>();
      void reply(RequestOptions o, RequestInterceptorHandler h) async {
        calls++;
        await gate.future;
        respond(o, h, baby(10));
      }

      final a = client('A', reply), b = client('A', reply);
      final first = a.get('/babies/one'), second = b.get('/babies/one');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      gate.complete();
      await Future.wait([first, second]);
      expect(calls, 1);
    },
  );
  test(
    'different accounts never reuse profile snapshots and logout clears them',
    () async {
      var calls = 0;
      void reply(RequestOptions o, RequestInterceptorHandler h) {
        calls++;
        respond(o, h, baby(calls));
      }

      final a = client('A', reply), b = client('B', reply);
      await a.get('/babies/one');
      await b.get('/babies/one');
      expect(calls, 2);
      CareRevisions.clear();
      await a.get('/babies/one');
      expect(calls, 3);
    },
  );
  test('record writes and explicit fresh reads invalidate snapshots', () async {
    var reads = 0;
    final api = client('A', (o, h) {
      if (o.method == 'GET') {
        reads++;
        respond(o, h, baby(reads));
      } else {
        respond(o, h, {});
      }
    });
    await api.get('/babies/one');
    await api.get('/babies/one');
    expect(reads, 1);
    await api.put('/babies/one/trackers/feeding', data: []);
    await api.get('/babies/one');
    expect(reads, 2);
    await api.get('/babies/one', options: Options(extra: {'fresh': true}));
    expect(reads, 3);
  });
  test('an old in-flight read cannot repopulate cache after a write', () async {
    var reads = 0;
    final gate = Completer<void>();
    final api = client('A', (o, h) async {
      if (o.method != 'GET') {
        respond(o, h, {});
        return;
      }
      reads++;
      if (reads == 1) {
        await gate.future;
        respond(o, h, baby(1));
      } else {
        respond(o, h, baby(2));
      }
    });
    final old = api.get('/babies/one');
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await api.put('/babies/one/trackers/feeding', data: []);
    gate.complete();
    await old;
    final current = await api.get('/babies/one');
    expect(current.data['data']['tracker_data']['feeding'][0]['amount_ml'], 2);
    expect(reads, 2);
  });
  test('failed reads are not cached', () async {
    var calls = 0;
    final api = client('A', (o, h) {
      calls++;
      if (calls == 1) {
        h.reject(
          DioException(
            requestOptions: o,
            type: DioExceptionType.connectionError,
          ),
          true,
        );
      } else {
        respond(o, h, baby(2));
      }
    });
    await expectLater(api.get('/babies/one'), throwsA(isA<DioException>()));
    await api.get('/babies/one');
    expect(calls, 2);
  });
}
