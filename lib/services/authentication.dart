import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationHelpler {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in method
  Future<String?> signIn(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      // Check if the user is verified
      if (!userCredential.user!.emailVerified) {
        await _auth.signOut(); // Sign out if not verified
        return 'Please verify your email first.';
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Sign up method
  Future<String?> signUp(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      // Send verification email
      await userCredential.user?.sendEmailVerification();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Sign out method
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if user is verified
  Future<bool> isUserVerified() async {
    User? user = _auth.currentUser;
    return user != null && user.emailVerified;
  }




}
