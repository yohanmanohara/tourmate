// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobileappdev/layout.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter/material.dart';

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

    final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    String idToken = (await userCredential.user!.getIdToken())!;

    print("Firebase ID Token: $idToken");
    
    // Store token in SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', idToken);

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
        MaterialPageRoute(builder: (context) => SiteLayout()), // Ensure DashboardScreen exists
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
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String idToken = (await userCredential.user!.getIdToken())!;

      print("Firebase ID Token: $idToken");
      
      // Store token in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', idToken);

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
          MaterialPageRoute(builder: (context) => SiteLayout()), // Ensure DashboardScreen exists
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



  }








