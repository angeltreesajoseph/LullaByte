import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;
  final FirebaseAuth _auth;
  User? get currentUser => _auth.currentUser;
  Future<UserCredential> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
  Future<UserCredential> register(String email, String password, String displayName) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
    await credential.user?.updateDisplayName(displayName.trim());
    return credential;
  }
  Future<void> signOut() => _auth.signOut();
}
