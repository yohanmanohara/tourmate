import 'package:flutter/material.dart';
import 'package:mobileappdev/layout.dart';
import 'package:mobileappdev/pages/authentication/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthValidate extends StatefulWidget {
  const AuthValidate({super.key});

  @override
  State<AuthValidate> createState() => _AuthValidateState();
}

class _AuthValidateState extends State<AuthValidate> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print("initState running...");
    checkLoginStatus(); // Directly calling instead of addPostFrameCallback
  }

  Future<void> checkLoginStatus() async {
    try {
      print("checkLoginStatus started...");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      print("Auth Token: $token"); // Debugging  

      await Future.delayed(const Duration(seconds: 2)); // Simulating loading  

      if (!mounted) return;  

      setState(() {
        isLoading = true;
      });

      print("Navigating to: ${token != null && token.isNotEmpty ? 'SiteLayout' : 'Login'}");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => token != null && token.isNotEmpty ? const SiteLayout() :  Login(),
        ),
      );
    } catch (e) {
      print("Error in checkLoginStatus: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : const Text('Checking authentication...'),
      ),
    );
  }
}
