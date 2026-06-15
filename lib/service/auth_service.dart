import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream to listen to authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current logged-in user
  User? get currentUser => _auth.currentUser;

  // Sign in with Email and Password
  Future<UserCredential?> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  // Sign up with Email, Username, and Password
  Future<UserCredential?> signUp(String email, String username, String password) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    // Update Firebase user profile with display name
    await userCredential.user?.updateDisplayName(username.trim());

    // Save user details into Firestore "users" collection
    await _db.collection('users').doc(userCredential.user?.uid).set({
      'uid': userCredential.user?.uid,
      'email': email.trim(),
      'username': username.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'favoriteCities': [],
      'temperatureUnit': 'C',
      'darkMode': true,
    });

    return userCredential;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Change Password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user != null && user.email != null) {
      // Re-authenticate first
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      // Update to new password
      await user.updatePassword(newPassword);
    } else {
      throw Exception('Không tìm thấy người dùng hiện tại');
    }
  }
}
