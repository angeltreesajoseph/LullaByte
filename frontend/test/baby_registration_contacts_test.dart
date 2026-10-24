import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lullabyte/features/authentication/presentation/widgets/auth_form_controls.dart';
import 'package:lullabyte/features/baby_management/data/baby_api.dart';
import 'package:lullabyte/features/baby_management/presentation/screens/baby_registration_screen.dart';

void main() {
  test(
    'creation sends each baby’s own contacts; omitted contacts stay optional',
    () async {
      final bodies = <Map<String, dynamic>>[];
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) {
            expect(o.path, '/babies');
            bodies.add(Map<String, dynamic>.from(o.data as Map));
            h.resolve(
              Response(requestOptions: o, statusCode: 201, data: {'data': {}}),
            );
          },
        ),
      );
      final api = BabyApi(dio);
      await api.create(
        name: 'Anna',
        parentPhone: ' +91 11111 ',
        pediatricianPhone: ' 22222 ',
      );
      await api.create(
        name: 'Ben',
        parentPhone: '33333',
        pediatricianPhone: '44444',
      );
      await api.create(name: 'No contacts');
      expect(bodies[0]['parent_phone'], '+91 11111');
      expect(bodies[0]['pediatrician_phone'], '22222');
      expect(bodies[1]['parent_phone'], '33333');
      expect(bodies[1]['pediatrician_phone'], '44444');
      expect(bodies[2].containsKey('parent_phone'), isFalse);
      expect(bodies[2].containsKey('pediatrician_phone'), isFalse);
    },
  );

  testWidgets(
    'both forms contain matching optional phone fields without copying values',
    (tester) async {
      GoogleFonts.config.allowRuntimeFetching = false;
      tester.view.physicalSize = const Size(430, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final router = GoRouter(routes: [GoRoute(path: '/', builder: (_, _) => const BabyRegistrationScreen())]);
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Join a baby’s care team'), findsOneWidget);
      AuthTextField field(String key) =>
          tester.widget<AuthTextField>(find.byKey(ValueKey(key)));
      expect(find.text('Pediatrician Name (optional)'), findsOneWidget);
      expect(find.text('Hospital Name (optional)'), findsOneWidget);
      expect(field('baby_parent_phone').validator(''), isNull);
      expect(field('baby_pediatrician_phone').validator(''), isNull);
      expect(field('baby_parent_phone').validator('invalid phone'), isNotNull);
      expect(field('baby_parent_phone').validator('+91 (123) 456-789'), isNull);
      field('baby_parent_phone').controller.text = '11111';
      field('baby_pediatrician_phone').controller.text = '22222';
      await tester.ensureVisible(find.byType(Switch));
      await tester.tap(find.byType(Switch));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Pediatrician Name (optional)'), findsNWidgets(2));
      expect(find.text('Hospital Name (optional)'), findsNWidgets(2));
      expect(field('twin_parent_phone').controller.text, isEmpty);
      expect(field('twin_pediatrician_phone').controller.text, isEmpty);
      expect(field('twin_parent_phone').validator(''), isNull);
      expect(
        field('twin_pediatrician_phone').keyboardType,
        TextInputType.phone,
      );
      field('twin_parent_phone').controller.text = '33333';
      expect(field('baby_parent_phone').controller.text, '11111');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
