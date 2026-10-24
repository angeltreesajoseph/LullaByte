import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lullabyte/features/family_sharing/application/shared_care_connection.dart';
import 'package:lullabyte/features/family_sharing/presentation/screens/shared_care_activity_screen.dart';

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);
  test('invitation parsing supports links and codes, not arbitrary text', () {
    const id = '12345678-1234-4234-8234-123456789012';
    expect(
      PendingCareInvitation.parse(
        'https://lullabyte-api.onrender.com/join/$id',
      ),
      id,
    );
    expect(
      PendingCareInvitation.parse('lullabyte://app/join?invitation=$id'),
      id,
    );
    expect(PendingCareInvitation.parse('not an invitation'), isNull);
  });
  testWidgets(
    'care activity and chat show real actor, accepted viewer can message',
    (tester) async {
      final api = Dio();
      api.interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) {
            expect(o.path, '/sharing/babies/one/activity');
            h.resolve(
              Response(
                requestOptions: o,
                data: {
                  'data': {
                    'baby_name': 'Anna',
                    'role': 'viewer',
                    'can_chat': true,
                    'events': [
                      {
                        'id': 1,
                        'actor_name': 'Caregiver',
                        'kind': 'feeding',
                        'summary': 'Added feeding records',
                        'created_at': '2026-10-21T10:00:00Z',
                        'can_delete': false,
                      },
                      {
                        'id': 2,
                        'actor_name': 'Parent',
                        'kind': 'chat',
                        'summary': 'New care-team message',
                        'message': 'How was lunch?',
                        'created_at': '2026-10-21T10:01:00Z',
                        'can_delete': false,
                      },
                    ],
                  },
                },
              ),
            );
          },
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: SharedCareActivityScreen(babyId: 'one', api: api),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Added feeding records'), findsOneWidget);
      expect(find.text('Caregiver'), findsOneWidget);
      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();
      expect(find.text('How was lunch?'), findsOneWidget);
      expect(find.byTooltip('Send message'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
