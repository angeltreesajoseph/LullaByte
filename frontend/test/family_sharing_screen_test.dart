import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lullabyte/features/baby_management/application/baby_profile_store.dart';
import 'package:lullabyte/features/family_sharing/presentation/screens/family_sharing_screen.dart';

void main() {
  test('verification prompt is only for unverified invitation recipients', () {
    expect(
      needsInvitationVerification(
        signedIn: true,
        emailVerified: false,
        reviewingInvitation: false,
      ),
      isFalse,
    ); // Parent managing sharing.
    expect(
      needsInvitationVerification(
        signedIn: true,
        emailVerified: false,
        reviewingInvitation: true,
      ),
      isTrue,
    );
    expect(
      needsInvitationVerification(
        signedIn: true,
        emailVerified: true,
        reviewingInvitation: true,
      ),
      isFalse,
    );
    expect(
      needsInvitationVerification(
        signedIn: false,
        emailVerified: false,
        reviewingInvitation: true,
      ),
      isFalse,
    );
  });
  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(430, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    BabyProfileStore.select({'id': 'one', 'name': 'Anna'});
  }

  Dio client(
    List<Map<String, dynamic>> shares,
    List<RequestOptions> writes, {
    bool viewer = false,
  }) {
    final api = Dio();
    api.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) {
          dynamic data;
          if (o.path == '/babies') {
            data = [
              {
                'id': 'one',
                'name': 'Anna',
                'access_role': viewer ? 'viewer' : 'owner',
              },
              if (!viewer) {'id': 'two', 'name': 'Ben', 'access_role': 'owner'},
            ];
          } else if (o.method == 'POST' &&
              o.path.startsWith('/sharing/babies/')) {
            writes.add(o);
            final entry = <String, dynamic>{
              'id': 'new',
              'baby_id': o.path.split('/').last,
              'baby_name': 'Anna',
              'email': o.data['email'],
              'role': o.data['role'],
              'status': 'pending',
              'expires_at': '2099-01-01T00:00:00Z',
              'is_owner': true,
              'invitation_url': 'https://example.com/join/new',
            };
            shares.add(entry);
            data = entry;
          } else if (o.method == 'POST' && o.path.endsWith('/accept')) {
            writes.add(o);
            shares.firstWhere(
              (s) => o.path == '/sharing/${s['id']}/accept',
            )['status'] = 'accepted';
            data = {};
          } else if (o.method == 'PATCH') {
            writes.add(o);
            shares.firstWhere(
              (s) => o.path.endsWith(s['id'] as String),
            )['role'] = o.data['role'];
            data = {};
          } else if (o.method == 'DELETE') {
            writes.add(o);
            shares.removeWhere((s) => o.path.endsWith(s['id'] as String));
            data = {};
          } else {
            data = shares;
          }
          h.resolve(Response(requestOptions: o, data: {'data': data}));
        },
      ),
    );
    return api;
  }

  Map<String, dynamic> member(String baby, String email, {bool owner = true}) =>
      {
        'id': baby,
        'baby_id': baby,
        'baby_name': baby,
        'email': email,
        'role': 'viewer',
        'status': 'accepted',
        'is_owner': owner,
      };

  testWidgets(
    'invite is modal, validates and creates link for selected baby only',
    (tester) async {
      size(tester);
      final shares = <Map<String, dynamic>>[], writes = <RequestOptions>[];
      await tester.pumpWidget(
        MaterialApp(home: FamilySharingScreen(api: client(shares, writes))),
      );
      await tester.pumpAndSettle();
      expect(find.text('Their account email'), findsNothing);
      expect(find.text('Activity & chat'), findsNothing);
      expect(find.text('Open chat'), findsNothing);
      expect(find.text('Send email verification'), findsNothing);
      expect(find.text('Review invitation'), findsNothing);
      await tester.tap(find.text('Invite caregiver'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create invitation'));
      await tester.pump();
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'care@example.com');
      await tester.tap(find.text('Create invitation'));
      await tester.pumpAndSettle();
      expect(writes.single.path, '/sharing/babies/one');
      expect(find.text('Copy invitation link'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('care@example.com'), findsOneWidget);
      expect(find.text('Pending invitations'), findsOneWidget);
      expect(find.text('Cancel invitation'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'baby selector isolates team; parent menu saves permissions and removal',
    (tester) async {
      size(tester);
      final shares = [
        member('one', 'anna-care@example.com'),
        member('two', 'ben-care@example.com'),
      ];
      final writes = <RequestOptions>[];
      await tester.pumpWidget(
        MaterialApp(home: FamilySharingScreen(api: client(shares, writes))),
      );
      await tester.pumpAndSettle();
      expect(find.text('anna-care@example.com'), findsOneWidget);
      expect(find.text('ben-care@example.com'), findsNothing);
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ben').last);
      await tester.pumpAndSettle();
      expect(find.text('anna-care@example.com'), findsNothing);
      expect(find.text('ben-care@example.com'), findsOneWidget);
      expect(BabyProfileStore.id, 'two');
      await tester.tap(find.byKey(const ValueKey('member_menu_two')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Manage care'));
      await tester.pumpAndSettle();
      expect(writes.last.path, '/sharing/two');
      expect(shares.last['role'], 'caregiver');
      await tester.tap(find.byKey(const ValueKey('member_menu_two')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove access'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Remove access'));
      await tester.pumpAndSettle();
      expect(shares, hasLength(1));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'incoming invitations offer accept or decline without parent controls',
    (tester) async {
      size(tester);
      final incoming = member('one', 'viewer@example.com', owner: false)
        ..['status'] = 'pending'
        ..['expires_at'] = '2099-01-01T00:00:00Z';
      final writes = <RequestOptions>[];
      await tester.pumpWidget(
        MaterialApp(
          home: FamilySharingScreen(
            api: client([incoming], writes, viewer: true),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);
      expect(find.text('Invite caregiver'), findsNothing);
      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();
      expect(writes.single.path, '/sharing/one/accept');
      expect(find.text('Pending invitations'), findsNothing);
      expect(find.text('Leave care team'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'viewer has no management controls and one notification switch reflects saved state',
    (tester) async {
      size(tester);
      var enabled = true;
      final writes = <RequestOptions>[];
      await tester.pumpWidget(
        MaterialApp(
          home: FamilySharingScreen(
            api: client(
              [member('one', 'viewer@example.com', owner: false)],
              writes,
              viewer: true,
            ),
            notificationStatus: () async => enabled,
            setNotifications: (value) async {
              enabled = value;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Invite caregiver'), findsNothing);
      expect(find.byType(PopupMenuButton<String>), findsNothing);
      expect(find.byType(SwitchListTile), findsOneWidget);
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isTrue,
      );
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      expect(enabled, isFalse);
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isFalse,
      );
      expect(writes, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );
}
