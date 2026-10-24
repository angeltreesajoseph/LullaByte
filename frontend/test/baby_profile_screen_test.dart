import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lullabyte/features/baby_management/application/baby_profile_store.dart';
import 'package:lullabyte/features/baby_management/presentation/screens/baby_profile_screen.dart';

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);
  testWidgets(
    'simple profile follows selected twin and keeps original sharing card',
    (tester) async {
      tester.view.physicalSize = const Size(430, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final one = <String, dynamic>{
        'id': 'one',
        'name': 'Anna',
        'gender': 'female',
        'blood_group': 'A+',
        'parent_phone': '+91 11111',
        'pediatrician_phone': '22222',
        'access_role': 'owner',
      };
      final two = <String, dynamic>{
        'id': 'two',
        'name': 'Ben',
        'gender': 'male',
        'blood_group': 'B-',
        'parent_phone': '+91 33333',
        'access_role': 'viewer',
      };
      BabyProfileStore.select(one);
      await tester.pumpWidget(const MaterialApp(home: BabyProfileScreen()));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(find.text('Anna'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('+91 11111'), findsOneWidget);
      expect(find.text('Family Sharing'), findsOneWidget);
      expect(find.text('Join a baby’s care team'), findsOneWidget);
      for (final removed in [
        'Growth Overview',
        'Care Summary',
        'Medical',
        'Twin Mode',
        'Memories',
        'Share Profile',
        'Export PDF',
      ]) {
        expect(find.text(removed), findsNothing);
      }
      expect(find.text('Registration measurements'), findsOneWidget);
      BabyProfileStore.select(two);
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(find.text('Ben'), findsOneWidget);
      expect(find.text('Anna'), findsNothing);
      expect(find.text('+91 33333'), findsOneWidget);
      expect(find.text('+91 11111'), findsNothing);
      expect(find.text('Edit Profile'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'edit stays bound to original baby and saves contacts without inventing DOB or blood group',
    (tester) async {
      tester.view.physicalSize = const Size(430, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final one = <String, dynamic>{
        'id': 'one',
        'name': 'Anna',
        'gender': 'female',
        'parent_phone': '11111',
        'access_role': 'owner',
      };
      final two = <String, dynamic>{
        'id': 'two',
        'name': 'Ben',
        'access_role': 'owner',
      };
      BabyProfileStore.babies = [one, two];
      BabyProfileStore.select(one);
      final api = Dio();
      Map? saved;
      api.interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) {
            expect(o.method, 'PATCH');
            expect(o.path, '/babies/one');
            saved = o.data as Map;
            h.resolve(
              Response(
                requestOptions: o,
                data: {
                  'data': {...one, ...o.data as Map},
                },
              ),
            );
          },
        ),
      );
      await tester.pumpWidget(MaterialApp(home: BabyProfileScreen(api: api)));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      await tester.ensureVisible(find.text('Edit Profile'));
      await tester.tap(find.text('Edit Profile'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      final phone = find.widgetWithText(
        TextFormField,
        'Parent contact (optional)',
      );
      await tester.ensureVisible(phone);
      await tester.enterText(phone, '+91 55555');
      BabyProfileStore.select(two);
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      await tester.ensureVisible(find.text('Save Changes'));
      await tester.tap(find.text('Save Changes'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(saved!['parent_phone'], '+91 55555');
      expect(saved!['birth_date'], isNull);
      expect(saved!['blood_group'], isNull);
      expect(saved!['gender'], 'female');
      expect(BabyProfileStore.id, 'two');
      expect(BabyProfileStore.babies.first['parent_phone'], '+91 55555');
      expect(tester.takeException(), isNull);
    },
  );
}
