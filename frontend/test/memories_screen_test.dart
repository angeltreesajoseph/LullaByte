import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lullabyte/features/baby_management/application/baby_profile_store.dart';
import 'package:lullabyte/features/gallery/presentation/screens/gallery_screen.dart';

const png =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=';
Map<String, dynamic> photo(String id, String date, {bool favorite = false}) => {
  'id': id,
  'title': id,
  'date': date,
  'photo_data': png,
  'favorite': favorite,
};
Map<String, dynamic> baby(
  String id,
  List<Map<String, dynamic>> rows, {
  String role = 'owner',
}) => {
  'id': id,
  'name': id,
  'access_role': role,
  'tracker_data': {'memories': rows},
  'tracker_revisions': {'memories': '1'},
};
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.pump();
}

Future<void> open(
  WidgetTester tester,
  Dio api,
  Map<String, dynamic> profile, {
  Future<XFile?> Function(ImageSource)? picker,
}) async {
  tester.view.physicalSize = const Size(430, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  BabyProfileStore.select(profile);
  await tester.pumpWidget(
    MaterialApp(
      home: GalleryScreen(api: api, pickPhoto: picker),
    ),
  );
  await settle(tester);
}

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(() {
    BabyProfileStore.id = null;
    BabyProfileStore.data = {};
    BabyProfileStore.babies = [];
  });
  testWidgets('add photo saves without title and preserves existing photos', (
    tester,
  ) async {
    final profile = baby('one', [photo('Existing', '2020-01-01')]);
    final writes = <RequestOptions>[];
    final api = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) {
            if (o.method == 'PUT') writes.add(o);
            h.resolve(Response(requestOptions: o, data: {'data': profile}));
          },
        ),
      );
    await open(
      tester,
      api,
      profile,
      picker: (_) async => XFile.fromData(
        base64Decode(png),
        name: 'photo.png',
        mimeType: 'image/png',
      ),
    );
    await tester.tap(find.text('Add Photo'));
    await settle(tester);
    await tester.tap(find.text('Choose from gallery'));
    await settle(tester);
    expect(find.text('Memory title (optional)'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await settle(tester);
    expect(writes, hasLength(1));
    expect((writes.single.data as List).length, 2);
    expect((writes.single.data as List).first['title'], 'Memory');
    expect((writes.single.data as List).first['photo_data'], png);
    expect((writes.single.data as List).last['title'], 'Existing');
    expect(find.text('Memory saved.'), findsOneWidget);
    expect(find.textContaining("Couldn't access"), findsNothing);
  });
  testWidgets('large gallery shows a bounded batch and allows more photos', (
    tester,
  ) async {
    final profile = baby(
      'one',
      List.generate(
        60,
        (i) => photo(
          'Photo $i',
          DateFormat(
            'yyyy-MM-dd',
          ).format(DateTime(2020, 1, 1).add(Duration(days: i))),
        ),
      ),
    );
    final api = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) =>
              h.resolve(Response(requestOptions: o, data: {'data': profile})),
        ),
      );
    await open(tester, api, profile);
    final before = tester
        .widget<GridView>(find.byType(GridView))
        .childrenDelegate
        .estimatedChildCount;
    expect(before, 24);
    await tester.ensureVisible(find.text('Show more photos'));
    await settle(tester);
    await tester.tap(find.text('Show more photos'));
    await settle(tester);
    expect(
      tester
          .widget<GridView>(find.byType(GridView))
          .childrenDelegate
          .estimatedChildCount,
      48,
    );
    expect(
      (BabyProfileStore.data['tracker_data'] as Map)['memories'],
      hasLength(60),
    );
  });
  testWidgets(
    'one add action, no demo/video controls, real date and favorite filters',
    (tester) async {
      final profile = baby('Anna', [
        photo('Today photo', DateFormat('yyyy-MM-dd').format(DateTime.now())),
        photo('Old photo', '2020-01-01', favorite: true),
      ]);
      final api = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (o, h) =>
                h.resolve(Response(requestOptions: o, data: {'data': profile})),
          ),
        );
      await open(tester, api, profile);
      expect(find.text('Add Photo'), findsOneWidget);
      expect(find.text('Add Video'), findsNothing);
      expect(find.text('Videos'), findsNothing);
      expect(find.text('Today photo'), findsOneWidget);
      expect(find.text('Old photo'), findsOneWidget);
      await tester.tap(find.text('Favorites').first);
      await settle(tester);
      expect(find.text('Today photo'), findsNothing);
      expect(find.text('Old photo'), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(-220, 0));
      await settle(tester);
      await tester.tap(find.text('This Month').first);
      await settle(tester);
      expect(find.text('Today photo'), findsOneWidget);
      expect(find.text('Old photo'), findsNothing);
      await tester.tap(find.text('Add Photo'));
      await settle(tester);
      expect(find.text('Take a photo'), findsOneWidget);
      expect(find.text('Choose from gallery'), findsOneWidget);
    },
  );
  testWidgets(
    'edit and delete save only selected baby; failed favorite leaves saved data intact',
    (tester) async {
      final profile = baby('one', [photo('Original', '2020-01-01')]);
      final writes = <RequestOptions>[];
      bool fail = true;
      final api = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (o, h) {
              if (o.method == 'PUT') {
                writes.add(o);
                if (fail) {
                  h.reject(
                    DioException(
                      requestOptions: o,
                      response: Response(requestOptions: o, statusCode: 500),
                    ),
                  );
                  return;
                }
              }
              h.resolve(Response(requestOptions: o, data: {'data': profile}));
            },
          ),
        );
      await open(tester, api, profile);
      await tester.tap(find.text('Original'));
      await settle(tester);
      await tester.tap(find.bySemanticsLabel('Add to favorites').last);
      await settle(tester);
      expect(
        (BabyProfileStore.data['tracker_data']
            as Map)['memories'][0]['favorite'],
        false,
      );
      expect(find.textContaining('Memory could not be saved'), findsOneWidget);
      fail = false;
      await tester.tap(find.text('Edit Memory'));
      await settle(tester);
      await tester.enterText(find.byType(TextField), 'Updated');
      await tester.tap(find.text('Save'));
      await settle(tester);
      expect(find.text('Updated'), findsOneWidget);
      expect(writes.last.path, '/babies/one/trackers/memories');
      expect((writes.last.data as List).single['title'], 'Updated');
      await tester.tap(find.text('Updated'));
      await settle(tester);
      await tester.tap(find.text('Delete Memory'));
      await settle(tester);
      await tester.tap(find.text('Cancel'));
      await settle(tester);
      expect(writes.length, 2);
      await tester.tap(find.text('Delete Memory'));
      await settle(tester);
      await tester.tap(find.text('Delete'));
      await settle(tester);
      expect(writes.last.data, isEmpty);
      expect(find.text('Start your baby memory book'), findsOneWidget);
    },
  );
  testWidgets('switching twins follows records and view-only hides mutations', (
    tester,
  ) async {
    final one = baby('Anna', [photo('Anna photo', '2020-01-01')]);
    final two = baby('Ben', [photo('Ben photo', '2020-01-01')], role: 'viewer');
    final api = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) => h.resolve(
            Response(
              requestOptions: o,
              data: {'data': o.path.endsWith('Anna') ? one : two},
            ),
          ),
        ),
      );
    await open(tester, api, one);
    BabyProfileStore.select(two);
    await settle(tester);
    expect(find.text('Anna photo'), findsNothing);
    expect(find.text('Ben photo'), findsOneWidget);
    expect(find.text('Add Photo'), findsNothing);
    await tester.tap(find.text('Ben photo'));
    await settle(tester);
    expect(find.text('Edit Memory'), findsNothing);
    expect(find.text('Delete Memory'), findsNothing);
  });
}
