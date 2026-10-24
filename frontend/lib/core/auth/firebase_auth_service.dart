import 'package:firebase_auth/firebase_auth.dart';
import '../../features/vaccination/application/vaccination_reminders.dart';
import '../../features/feeding/application/feeding_reminders.dart';
import '../../features/family_sharing/application/shared_care_notifications.dart';
import '../../features/baby_management/application/baby_profile_store.dart';
import '../network/care_dio.dart';

class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;
  final FirebaseAuth _auth;
  User? get currentUser => _auth.currentUser;
  Future<UserCredential> signIn(String email, String password) async {
    CareRevisions.clear();
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (credential.user != null)
      VaccinationReminders.resumeForUser(credential.user!.uid);
    if (credential.user != null) FeedingReminders.resume(credential.user!.uid);
    return credential;
  }

  Future<UserCredential> register(
    String email,
    String password,
    String displayName,
  ) async {
    CareRevisions.clear();
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.updateDisplayName(displayName.trim());
    if (credential.user != null)
      VaccinationReminders.resumeForUser(credential.user!.uid);
    if (credential.user != null) FeedingReminders.resume(credential.user!.uid);
    return credential;
  }

  Future<void> signOut() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await SharedCareNotifications.disable();
      } catch (_) {
        /* Sign-out must still complete. */
      }
      try {
        await VaccinationReminders.cancelForUser(user.uid);
      } catch (_) {
        // OS notification failures must not prevent account sign-out.
      }
      try {
        await FeedingReminders.cancelForUser(user.uid);
      } catch (_) {
        // Notification failures must not prevent sign-out.
      }
    }
    await _auth.signOut();
    CareRevisions.clear();
    BabyProfileStore.babies = [];
    BabyProfileStore.select({});
  }
}
