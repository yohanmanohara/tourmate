import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:mobileappdev/layout.dart';
import 'package:mobileappdev/pages/authentication/login.dart';
import '../services/firebase_options.dart';
import '../controllers/menu_controller.dart' as menu_controller;
import '../controllers/navigation_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  print("Main function started...");
  WidgetsFlutterBinding.ensureInitialized(); // Ensure initialization happens first.

  // Firebase initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Firebase initialized...");

  // Initialize controllers
  Get.put(menu_controller.MenuController());
  Get.put(NavigationController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes the debug banner
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthValidate(), // Custom widget for authentication
    );
  }
}

class AuthValidate extends StatefulWidget {
  const AuthValidate({super.key});

  @override
  _AuthValidateState createState() => _AuthValidateState();
}

class _AuthValidateState extends State<AuthValidate> {
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    print("initState running...");
    checkLoginStatus(); // Directly calling instead of addPostFrameCallback
  }

  // This function checks login status from SharedPreferences
  Future<void> checkLoginStatus() async {
    try {
      print("checkLoginStatus started...");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      print("Auth Token: $token"); // Debugging  

      await Future.delayed(const Duration(seconds: 2)); // Simulating loading  

      if (!mounted) return;  

      setState(() {
        isLoading = false; // Stop loading once check is done
      });

      print("Navigating to: ${token != null && token.isNotEmpty ? 'SiteLayout' : 'Login'}");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => token != null && token.isNotEmpty 
              ? const SiteLayout() // Navigate to the site layout if authenticated
              :  Login(), // Otherwise, go to the login page
        ),
      );
    } catch (e) {
      print("Error in checkLoginStatus: $e");
      setState(() {
        isLoading = false; // Stop loading even if there’s an error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color
      body: Center(
        child: isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/logo.png', // Replace with the path to your logo
                    height: 120,
                    width: 120,
                  ),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(), // Loading spinner
                ],
              )
            : const Text(
                'Checking Authentication...',
                style: TextStyle(fontSize: 18),
              ),
      ),
    );
  }
}
