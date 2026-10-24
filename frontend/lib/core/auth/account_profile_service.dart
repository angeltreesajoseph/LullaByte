import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/family_sharing/application/shared_care_connection.dart';

class AccountProfile {
  const AccountProfile({
    required this.name,
    required this.email,
    this.photoUrl,
    this.photoData,
  });
  final String name, email;
  final String? photoUrl, photoData;
}

String accountSaveError(Object error) {
  if (error is DioException) {
    return switch (error.response?.statusCode) {
      401 => 'Please sign in again and retry.',
      404 || 405 =>
        'Account photo saving needs a server update. Please retry after deployment.',
      413 || 422 => 'Choose a smaller JPEG or PNG photo and retry.',
      500 || 503 =>
        'Account photo storage is not ready on the server. Please retry later.',
      _ => 'Could not connect to save your account. Please retry.',
    };
  }
  if (error is FirebaseException) {
    return error.code == 'network-request-failed'
        ? 'Could not connect. Check your internet connection and retry.'
        : 'Could not update your account name. Please retry.';
  }
  if (error is StateError) return error.message.toString();
  return 'Could not save your account. Please retry.';
}

/// Names remain in Firebase Auth; private avatar bytes use the existing backend.
class AccountProfileService {
  AccountProfileService({this.api});
  final Dio? api;
  String? _photoData;
  String? _photoOwner;
  int _photoVersion = 0;
  AccountProfile read() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Please sign in again.');
    return AccountProfile(
      name: user.displayName ?? '',
      email: user.email ?? '',
      photoUrl: user.photoURL,
      photoData: _photoOwner == user.uid ? _photoData : null,
    );
  }

  Future<AccountProfile> load() async {
    final version = _photoVersion;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Please sign in again.');
    final client = api ?? await sharedCareClient();
    final response = await client.get('/account/me/photo');
    if (FirebaseAuth.instance.currentUser?.uid != user.uid) {
      throw StateError('Your account changed. Please reopen Profile.');
    }
    if (version == _photoVersion) {
      _photoData = response.data['data']['photo_data'] as String?;
      _photoOwner = user.uid;
    }
    return read();
  }

  Future<AccountProfile> save(String name, Uint8List? photo) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Please sign in again.');
    if (photo != null) {
      _photoVersion++;
      final png =
          photo.length >= 8 &&
          photo[0] == 137 &&
          photo[1] == 80 &&
          photo[2] == 78 &&
          photo[3] == 71;
      final jpeg =
          photo.length >= 3 &&
          photo[0] == 255 &&
          photo[1] == 216 &&
          photo[2] == 255;
      if (!png && !jpeg) throw StateError('Choose a JPEG or PNG photo.');
      final data =
          'data:image/${png ? 'png' : 'jpeg'};base64,${base64Encode(photo)}';
      if (data.length > 500000) {
        throw StateError('Choose a smaller photo (under 375 KB).');
      }
      final client = api ?? await sharedCareClient();
      final response = await client.put(
        '/account/me/photo',
        data: {'photo_data': data},
      );
      _photoData = response.data['data']['photo_data'] as String?;
      _photoOwner = user.uid;
    }
    if (FirebaseAuth.instance.currentUser?.uid != user.uid) {
      throw StateError('Your account changed. Please reopen Profile.');
    }
    if (user.displayName != name.trim()) {
      await user.updateDisplayName(name.trim());
      await user.getIdToken(true);
    }
    return read();
  }
}
