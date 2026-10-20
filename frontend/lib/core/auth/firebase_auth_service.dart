import 'package:firebase_auth/firebase_auth.dart';
import '../../features/vaccination/application/vaccination_reminders.dart';

class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;
  final FirebaseAuth _auth;
  User? get currentUser => _auth.currentUser;
  Future<UserCredential> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (credential.user != null)
      VaccinationReminders.resumeForUser(credential.user!.uid);
    return credential;
  }

  Future<UserCredential> register(
    String email,
    String password,
    String displayName,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.updateDisplayName(displayName.trim());
    if (credential.user != null)
      VaccinationReminders.resumeForUser(credential.user!.uid);
    return credential;
  }

  Future<void> signOut() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await VaccinationReminders.cancelForUser(user.uid);
      } catch (_) {
        // OS notification failures must not prevent account sign-out.
      }
    }
    await _auth.signOut();
  }
}
