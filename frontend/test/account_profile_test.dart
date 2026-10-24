import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lullabyte/core/auth/account_profile_service.dart';
import 'package:lullabyte/features/baby_management/application/baby_profile_store.dart';
import 'package:lullabyte/features/baby_management/presentation/screens/account_profile_screen.dart';

class FakeAccount extends AccountProfileService {
  AccountProfile profile = const AccountProfile(
    name: 'Parent',
    email: 'parent@example.com',
  );
  bool fail = false;
  @override
  AccountProfile read() => profile;
  @override
  Future<AccountProfile> load() async => profile;
  @override
  Future<AccountProfile> save(String name, Uint8List? photo) async {
    if (fail) throw Exception('offline');
    return profile = AccountProfile(name: name, email: profile.email);
  }
}

void main() {
  test('backend photo errors give deployment and size guidance', () {
    DioException error(int status) => DioException(
      requestOptions: RequestOptions(path: '/account/me/photo'),
      response: Response(requestOptions: RequestOptions(), statusCode: status),
    );
    expect(accountSaveError(error(404)), contains('server update'));
    expect(accountSaveError(error(422)), contains('smaller JPEG or PNG'));
    expect(accountSaveError(error(401)), contains('sign in again'));
  });
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    BabyProfileStore.babies = [];
  });
  tearDown(() {
    BabyProfileStore.babies = [];
    BabyProfileStore.select({});
  });
  testWidgets('account stays above twins and saves its own name', (
    tester,
  ) async {
    final account = FakeAccount();
    final api = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) {
            h.resolve(
              Response(
                requestOptions: o,
                data: {
                  'data': [
                    {'id': 'one', 'name': 'Anna', 'access_role': 'owner'},
                    {'id': 'two', 'name': 'Ben', 'access_role': 'owner'},
                  ],
                },
              ),
            );
          },
        ),
      );
    await tester.pumpWidget(
      MaterialApp(
        home: AccountProfileScreen(service: account, api: api),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Parent'), findsOneWidget);
    expect(find.byKey(const ValueKey('account_baby_one')), findsOneWidget);
    expect(find.byKey(const ValueKey('account_baby_two')), findsOneWidget);
    await tester.tap(find.text('Edit account'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Updated parent');
    await tester.ensureVisible(find.text('Save account'));
    await tester.tap(find.text('Save account'));
    await tester.pumpAndSettle();
    expect(find.text('Updated parent'), findsOneWidget);
    expect(account.profile.email, 'parent@example.com');
    expect(BabyProfileStore.babies.map((b) => b['name']), ['Anna', 'Ben']);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'failed account save keeps editor open and does not claim success',
    (tester) async {
      final account = FakeAccount()..fail = true;
      final api = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (o, h) {
              h.resolve(Response(requestOptions: o, data: {'data': []}));
            },
          ),
        );
      await tester.pumpWidget(
        MaterialApp(
          home: AccountProfileScreen(service: account, api: api),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit account'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Unsaved');
      await tester.ensureVisible(find.text('Save account'));
      await tester.tap(find.text('Save account'));
      await tester.pumpAndSettle();
      expect(
        find.text('Could not save your account. Please retry.'),
        findsOneWidget,
      );
      expect(account.profile.name, 'Parent');
      await tester.pumpWidget(const SizedBox());
    },
  );
}
