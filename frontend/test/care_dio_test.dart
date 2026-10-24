import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lullabyte/core/network/care_dio.dart';

void main() {
  test('tracker writes carry the loaded revision for that baby only', () async {
    CareRevisions.clear();
    CareRevisions.remember({
      'id': 'one',
      'tracker_revisions': {'feeding': 'loaded-one'},
    });
    CareRevisions.remember({
      'id': 'two',
      'tracker_revisions': {'feeding': 'loaded-two'},
    });
    final api = careDio();
    final sent = <String?>[];
    api.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) {
          sent.add(o.headers['X-Care-Revision'] as String?);
          h.resolve(
            Response(
              requestOptions: o,
              data: {'data': []},
              headers: Headers.fromMap({
                'x-care-revision': ['saved-new'],
              }),
            ),
            true,
          );
        },
      ),
    );
    await api.put('/babies/one/trackers/feeding', data: []);
    await api.put('/babies/one/trackers/feeding', data: []);
    await api.put('/babies/two/trackers/feeding', data: []);
    expect(sent, ['loaded-one', 'saved-new', 'loaded-two']);
    CareRevisions.clear();
    await api.put('/babies/one/trackers/feeding', data: []);
    expect(sent.last, isNull);
  });
}
