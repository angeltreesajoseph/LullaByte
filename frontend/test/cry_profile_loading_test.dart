import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lullabyte/features/baby_management/application/baby_profile_store.dart';
import 'package:lullabyte/features/baby_management/application/profile_tracker.dart';

class Harness extends StatefulWidget {
  const Harness({super.key, required this.api});
  final Dio api;
  @override
  State<Harness> createState() => HarnessState();
}

class HarnessState extends State<Harness> with ProfileTracker<Harness> {
  List<Map<String, dynamic>> rows = [];
  @override
  String get trackerKind => 'cry';
  @override
  bool get allowSnapshotReady => true;
  @override
  Future<Dio> createTrackerClient() async => widget.api;
  @override
  List<Map<String, dynamic>> encodeEntries() => rows;
  @override
  void decodeEntries(List<Map<String, dynamic>> entries) => rows = entries;
  @override
  void initState() {
    super.initState();
    startTracker();
  }

  @override
  void dispose() {
    stopTracker();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Text(
      '${trackerReady ? "ready" : "waiting"}:${rows.map((r) => r['label']).join(",")}',
    ),
  );
}

Map<String, dynamic> baby(String id, {String role = 'caregiver'}) => {
  'id': id,
  'name': id,
  'access_role': role,
  'tracker_data': {
    'cry': [
      {'label': id},
    ],
  },
  'tracker_revisions': {'cry': '1'},
};

void main() {
  tearDown(() {
    BabyProfileStore.id = null;
    BabyProfileStore.data = {};
    BabyProfileStore.babies = [];
  });
  testWidgets(
    'cached selected baby is ready before history; old GET cannot erase a saved result',
    (tester) async {
      BabyProfileStore.select(baby('one'));
      final response = Completer<Response>();
      final api = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (o, h) async => h.resolve(await response.future),
          ),
        );
      final key = GlobalKey<HarnessState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Harness(key: key, api: api),
        ),
      );
      await tester.pump();
      expect(find.text('ready:one'), findsOneWidget);
      key.currentState!.setState(() {
        key.currentState!.acceptServerTrackerMutation();
        key.currentState!.rows = [
          {'label': 'new'},
        ];
      });
      response.complete(
        Response(
          requestOptions: RequestOptions(path: '/babies/one'),
          data: {'data': baby('one')},
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('ready:new'), findsOneWidget);
    },
  );
  testWidgets('viewer snapshot does not enable care recording', (tester) async {
    BabyProfileStore.select(baby('two', role: 'viewer'));
    final response = Completer<Response>();
    final api = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) async => h.resolve(await response.future),
        ),
      );
    await tester.pumpWidget(MaterialApp(home: Harness(api: api)));
    await tester.pump();
    expect(find.text('waiting:two'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    response.complete(
      Response(
        requestOptions: RequestOptions(path: '/babies/two'),
        data: {'data': baby('two', role: 'viewer')},
      ),
    );
    await tester.pumpAndSettle();
  });
  testWidgets('revoked permission clears cached records', (tester) async {
    BabyProfileStore.select(baby('one'));
    final api = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) => h.reject(
            DioException(
              requestOptions: o,
              response: Response(requestOptions: o, statusCode: 403),
            ),
          ),
        ),
      );
    await tester.pumpWidget(MaterialApp(home: Harness(api: api)));
    await tester.pumpAndSettle();
    expect(find.text('waiting:'), findsOneWidget);
  });
}
