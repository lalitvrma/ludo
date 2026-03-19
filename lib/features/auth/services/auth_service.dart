import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
  );

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      developer.log('Signed in with Google: ${userCredential.user!.uid}');
      return userCredential;
    } catch (e) {
      developer.log('Error signing in with Google: $e');
      return null;
    }
  }

  Future<UserCredential?> signInAsGuest() async {
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();
      developer.log('Signed in as guest: ${userCredential.user!.uid}');
      return userCredential;
    } catch (e) {
      developer.log('Error signing in as guest: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
