import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import './screen/onbording.dart';
import '../services/firebase_options.dart';
import '../screen/main_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screen/admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure initialization happens first.

  // Firebase initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes the debug banner
      title: 'TourMate',
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
  // ignore: library_private_types_in_public_api
  _AuthValidateState createState() => _AuthValidateState();
}

class _AuthValidateState extends State<AuthValidate> {
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    checkLoginStatus(); // Directly calling instead of addPostFrameCallback
  }

  // This function checks login status from SharedPreferences
  Future<void> checkLoginStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      // Debugging

      await Future.delayed(const Duration(seconds: 2)); // Simulating loading

      if (!mounted) return;

      setState(() {
        isLoading = false; // Stop loading once check is done
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => token != null && token.isNotEmpty
              ? AdminDashboardScreen() // Navigate to the site layout if authenticated
              : OnBoardingScreen(), // Otherwise, go to the login page
        ),
      );
    } catch (e) {
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
