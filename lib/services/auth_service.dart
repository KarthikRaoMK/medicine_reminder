import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userEmailKey = 'user_email';

  // Save login state & sign in to Firebase
  Future<void> login(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userEmailKey, email);
  }

  // Register in Firebase
  Future<void> register(String name, String email, String password) async {
    final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await userCredential.user?.updateDisplayName(name);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) return true;
    
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Get current user ID
  String? get currentUserId {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  // Get saved email
  Future<String?> getSavedEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) return user.email;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Logout and clear saved data
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userEmailKey);
  }

  // Clear all user data
  Future<void> clearAllData() async {
    await logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
