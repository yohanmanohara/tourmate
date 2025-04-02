import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screen/main_layout.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import '../screen/home_page.dart';
import '../screen/admin/admin_dashboard.dart';
import 'firestore_service.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  bool isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
    return regex.hasMatch(email);
  }

  // Store user session data
  Future<void> _storeUserSession(User user, String role) async {
    String idToken = await user.getIdToken() ?? '';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', idToken);
    await prefs.setString('uid', user.uid);
    await prefs.setString('email', user.email ?? '');
    await prefs.setString('role', role);
  }

  // Clear user session data on logout
  Future<void> _clearUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Navigate based on role
  void _navigateBasedOnRole(BuildContext context, String role) {
    if (role == 'admin') {
      Navigator.pushReplacementNamed(context, '/admin-dashboard');
    } else {
      Navigator.pushReplacementNamed(
          context, '/home'); // This will now go to MainLayout
    }
  }

  // Check if a user exists in Firestore, if not, create a new entry
  Future<String> _ensureUserExists(User user) async {
    UserModel? userData = await _firestoreService.getUserData(user.uid);

    if (userData == null) {
      // New user - create entry with default 'user' role
      await _firestoreService.createNewUser(user.uid, user.email ?? '');
      return 'user';
    }

    return userData.role;
  }

  Future<bool> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        toastification.show(
          context: context,
          title: const Text('Email and password cannot be empty'),
          autoCloseDuration: const Duration(seconds: 2),
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          alignment: Alignment.topCenter,
          backgroundColor: const Color.fromARGB(137, 194, 68, 68),
          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
          primaryColor: const Color.fromARGB(255, 235, 86, 86),
          borderRadius: BorderRadius.circular(20),
        );
        return false;
      }

      if (!isValidEmail(email)) {
        toastification.show(
          context: context,
          title: const Text('Please enter a valid email address'),
          autoCloseDuration: const Duration(seconds: 2),
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          alignment: Alignment.topCenter,
          backgroundColor: const Color.fromARGB(137, 194, 68, 68),
          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
          primaryColor: const Color.fromARGB(255, 235, 86, 86),
          borderRadius: BorderRadius.circular(20),
        );
        return false;
      }

      // Sign in with Firebase
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        // Get user role from Firestore
        final String role = await _ensureUserExists(user);

        // Store user session data
        await _storeUserSession(user, role);

        // Show success message
        toastification.show(
          context: context,
          title: const Text("Login successful!"),
          autoCloseDuration: const Duration(seconds: 2),
          type: ToastificationType.success,
          style: ToastificationStyle.fillColored,
          alignment: Alignment.topCenter,
          backgroundColor: const Color.fromARGB(137, 68, 194, 68),
          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
          primaryColor: const Color.fromARGB(255, 88, 223, 92),
          borderRadius: BorderRadius.circular(20),
        );

        // Add a slight delay for the toast to be visible, then navigate
        Future.delayed(const Duration(seconds: 1), () {
          _navigateAfterAuth(context, role);
        });

        return true; // Return true to indicate successful login
      }
      return false;
    } catch (e) {
      // Error handling
      toastification.show(
        context: context,
        title: Text("Error: $e"),
        autoCloseDuration: const Duration(seconds: 2),
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        alignment: Alignment.topCenter,
        backgroundColor: const Color.fromARGB(137, 194, 68, 68),
        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
        primaryColor: const Color.fromARGB(255, 235, 86, 86),
        borderRadius: BorderRadius.circular(20),
      );
      return false;
    }
  }

  // Signup function
  Future<void> signup({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        toastification.show(
          context: context,
          title: const Text('Email and password cannot be empty'),
          autoCloseDuration: const Duration(seconds: 2),
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          alignment: Alignment.topCenter,
          backgroundColor: const Color.fromARGB(137, 194, 68, 68),
          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
          primaryColor: const Color.fromARGB(255, 235, 86, 86),
          borderRadius: BorderRadius.circular(20),
        );
        return;
      }

      if (!isValidEmail(email)) {
        toastification.show(
          context: context,
          title: const Text('Please enter a valid email address'),
          autoCloseDuration: const Duration(seconds: 2),
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          alignment: Alignment.topCenter,
          backgroundColor: const Color.fromARGB(137, 194, 68, 68),
          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
          primaryColor: const Color.fromARGB(255, 235, 86, 86),
          borderRadius: BorderRadius.circular(20),
        );
        return;
      }

      // Create a new user with Firebase Authentication
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        // Create user document in Firestore with 'user' role
        await _firestoreService.createNewUser(user.uid, user.email ?? '');

        // Store session
        await _storeUserSession(user, 'user');

        // Success toast
        toastification.show(
          // ignore: use_build_context_synchronously
          context: context,
          title: const Text("Signup successful!"),
          autoCloseDuration: const Duration(seconds: 2),
          type: ToastificationType.success,
          // Existing toast styling...
        );

        // Navigate to MainLayout after a delay (all new users are regular users)
        Future.delayed(const Duration(seconds: 1), () {
          _navigateAfterAuth(context, 'user');
        });
      }
    } catch (e) {
      // Existing error handling...
    }
  }

  // google oauth
  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        scopes: [
          'email',
          'https://www.googleapis.com/auth/userinfo.profile',
        ],
        clientId:
            '', // Leave empty for Android - it uses the Google services JSON file
      ).signIn();

      if (googleUser == null) {
        // User canceled the sign-in

        toastification.show(
          // ignore: use_build_context_synchronously
          context: context,
          title: const Text("Google sign-in was canceled."),
          autoCloseDuration: const Duration(seconds: 2),
          type: ToastificationType.warning,
          style: ToastificationStyle.fillColored,
          alignment: Alignment.topCenter,
          backgroundColor: const Color.fromARGB(137, 194, 194, 68),
          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
          primaryColor: const Color.fromARGB(255, 235, 223, 86),
          borderRadius: BorderRadius.circular(20),
        );
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        toastification.show(
          // ignore: use_build_context_synchronously
          context: context,
          title: const Text("Google sign-in failed. Please try again."),
          autoCloseDuration: const Duration(seconds: 2),
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          alignment: Alignment.topCenter,
          backgroundColor: const Color.fromARGB(137, 194, 68, 68),
          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
          primaryColor: const Color.fromARGB(255, 235, 86, 86),
          borderRadius: BorderRadius.circular(20),
        );
        return null;
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      try {
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          // Get user role from Firestore or create new user
          final String role = await _ensureUserExists(user);

          // Store user session data
          await _storeUserSession(user, role);

          // Show success message
          toastification.show(
            // ignore: use_build_context_synchronously
            context: context,
            title: const Text("Google sign-in successful!"),
            autoCloseDuration: const Duration(seconds: 2),
            type: ToastificationType.success,
            style: ToastificationStyle.fillColored,
            alignment: Alignment.topCenter,
            backgroundColor: const Color.fromARGB(137, 68, 194, 68),
            foregroundColor: const Color.fromARGB(255, 0, 0, 0),
            primaryColor: const Color.fromARGB(255, 88, 223, 92),
            borderRadius: BorderRadius.circular(20),
          );

          // Add navigation after a short delay
          Future.delayed(const Duration(seconds: 1), () {
            _navigateAfterAuth(context, role);
          });

          // Return the user
          return user;
        } else {
          return null;
        }
      } catch (firebaseAuthException) {
        toastification.show(
          // ignore: use_build_context_synchronously
          context: context,
          title: Text("Firebase sign-in error: $firebaseAuthException"),
          autoCloseDuration: const Duration(seconds: 2),
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          alignment: Alignment.topCenter,
          backgroundColor: const Color.fromARGB(137, 194, 68, 68),
          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
          primaryColor: const Color.fromARGB(255, 235, 86, 86),
          borderRadius: BorderRadius.circular(20),
        );
        return null;
      }
    } catch (e) {
      // More specific error handling
      String errorMessage = "Google sign-in error";
      if (e.toString().contains("ApiException: 10:")) {
        errorMessage =
            "Google Sign-In configuration error. Please check Firebase setup.";
      } else if (e.toString().contains("network_error")) {
        errorMessage = "Network error. Please check your internet connection.";
      } else if (e is PlatformException) {
        errorMessage = "Sign-in error: ${e.message}";
      }

      toastification.show(
        // ignore: use_build_context_synchronously
        context: context,
        title: Text(errorMessage),
        autoCloseDuration: const Duration(seconds: 2),
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        alignment: Alignment.topCenter,
        backgroundColor: const Color.fromARGB(137, 194, 68, 68),
        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
        primaryColor: const Color.fromARGB(255, 235, 86, 86),
        borderRadius: BorderRadius.circular(20),
      );
      return null;
    }
  }

  // Sign out
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
      await _clearUserSession();

      // Navigate to login screen
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      toastification.show(
        context: context,
        title: Text("Error signing out: $e"),
        autoCloseDuration: const Duration(seconds: 2),
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        alignment: Alignment.topCenter,
        backgroundColor: const Color.fromARGB(137, 194, 68, 68),
        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
        primaryColor: const Color.fromARGB(255, 235, 86, 86),
        borderRadius: BorderRadius.circular(20),
      );
    }
  }

  // Check if user is logged in and return their role
  Future<Map<String, dynamic>> getCurrentUserRole() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? uid = prefs.getString('uid');
      String? role = prefs.getString('role');

      if (uid != null && role != null) {
        return {
          'isLoggedIn': true,
          'role': role,
          'uid': uid,
        };
      }

      // Check Firebase auth state as fallback
      User? user = _auth.currentUser;
      if (user != null) {
        UserModel? userData = await _firestoreService.getUserData(user.uid);
        if (userData != null) {
          // Update shared preferences
          await _storeUserSession(user, userData.role);
          return {
            'isLoggedIn': true,
            'role': userData.role,
            'uid': user.uid,
          };
        }
      }

      return {
        'isLoggedIn': false,
        'role': null,
        'uid': null,
      };
    } catch (e) {
      print('Error checking user role: $e');
      return {
        'isLoggedIn': false,
        'role': null,
        'uid': null,
      };
    }
  }

  Future<void> storeUserSession(User user, String role) async {
    try {
      String idToken = await user.getIdToken() ?? '';

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', idToken);
      await prefs.setString('uid', user.uid);
      await prefs.setString('email', user.email ?? '');
      await prefs.setString('role', role);
      await prefs.setString('displayName', user.displayName ?? '');
      await prefs.setString('photoURL', user.photoURL ?? '');
    } catch (e) {
      print('Error storing user session: $e');
      rethrow;
    }
  }

  // Create user with email and password
  Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error creating user with email and password: $e');
      rethrow;
    }
  }

  // Update your existing signUp method to check for preferences completion
  Future<void> _navigateAfterAuth(BuildContext context, String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasCompletedPreferences =
        prefs.getBool('hasCompletedPreferences') ?? false;

    if (role == 'admin') {
      Navigator.pushReplacementNamed(context, '/admin-dashboard');
    } else {
      // For regular users, check if they've completed preferences
      if (!hasCompletedPreferences) {
        Navigator.pushReplacementNamed(context, '/preferences');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }
}
