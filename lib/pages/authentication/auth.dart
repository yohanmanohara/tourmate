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
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo Section
              Image.asset(
                'assets/icons/logo.png', // Replace with the path to your logo
                height: 120,
                width: 120,
              ),
              SizedBox(height: 20),
              
              // Loading Indicator or Text
              isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Optional: Custom color for the loader
                    )
                  : const Text(
                      'Checking authentication...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
