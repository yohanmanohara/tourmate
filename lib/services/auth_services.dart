// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobileappdev/layout.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  bool isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
    return regex.hasMatch(email);
  }

  Future<void> login({
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

      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String idToken = (await userCredential.user!.getIdToken())!;

      print("Firebase ID Token: $idToken");
      // Get the current user
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        print("Current user: ${currentUser.email}");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', idToken);
      }

      // Success toast
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

      // Navigate to Dashboard after a delay (optional)
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  SiteLayout()), // Ensure DashboardScreen exists
        );
      });
    } on FirebaseAuthException catch (e) {
      String message = "An error occurred";
      if (e.code == 'user-not-found') {
        message = 'No user found with this email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      }

      // Error toast
      toastification.show(
        context: context,
        title: Text("Error code: ${e.code}, message: $message"),
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

      String idToken = (await userCredential.user!.getIdToken())!;

      print("Firebase ID Token: $idToken");

      // Get the current user
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        print("Current user: ${currentUser.email}");
        // You can store the token in SharedPreferences if needed
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', idToken);
      }
      // Success toast
      toastification.show(
        context: context,
        title: const Text("Signup successful!"),
        autoCloseDuration: const Duration(seconds: 2),
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        alignment: Alignment.topCenter,
        backgroundColor: const Color.fromARGB(137, 68, 194, 68),
        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
        primaryColor: const Color.fromARGB(255, 88, 223, 92),
        borderRadius: BorderRadius.circular(20),
      );

      // Navigate to Dashboard after a delay
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  SiteLayout()), // Ensure DashboardScreen exists
        );
      });
    } on FirebaseAuthException catch (e) {
      String message = "An error occurred";
      if (e.code == 'email-already-in-use') {
        message = 'This email is already in use.';
      } else if (e.code == 'weak-password') {
        message = 'Password should be at least 6 characters.';
      }

      // Error toast
      toastification.show(
        context: context,
        title: Text("Error code: ${e.code}, message: $message"),
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

  // google oauth
  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        print("Google sign-in canceled by user");
        toastification.show(
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
        print("Google Auth tokens are null");
        toastification.show(
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
          String idToken = (await user.getIdToken())!;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('authToken', idToken);

          // Success toast
          toastification.show(
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

          return user;
        } else {
          print("Firebase user is null after Google sign-in");
          return null;
        }
      } catch (firebaseAuthException) {
        print("Firebase sign-in with credential error: $firebaseAuthException");
        toastification.show(
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
      print("Google sign-in general error: $e");
      toastification.show(
        context: context,
        title: Text("Google sign-in error: $e"),
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
}
