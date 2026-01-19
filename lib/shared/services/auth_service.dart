import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(FirebaseAuth.instance);
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthService(this._auth);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In...');
      // Explicitly trigger the sign-in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('Google Sign-In cancelled by user.');
        return null;
      }

      print('Google User obtained: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print('Obtaining Firebase Credential...');
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Signing in to Firebase...');
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Keep verifyPhoneNumber for now in case we revert, or remove it if strictly asked.
  // ...
}
