import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import './screen/onbording.dart';
import '../services/firebase_options.dart';
import './screen/home_page.dart';
import './screen/admin/admin_dashboard.dart';
import './services/auth_services.dart';
import './screen/login.dart';
import './screen/signup.dart';
import './screen/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      debugShowCheckedModeBanner: false,
      title: 'TourMate',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthValidate(),
      routes: {
        '/login': (context) => const Login(),
        '/signup': (context) => const Signup(),
        '/home': (context) => const MainLayout(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        // Add other routes as needed
      },
    );
  }
}

class AuthValidate extends StatefulWidget {
  const AuthValidate({super.key});

  @override
  _AuthValidateState createState() => _AuthValidateState();
}

class _AuthValidateState extends State<AuthValidate> {
  bool isLoading = true;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    try {
      // Simulate loading time
      await Future.delayed(const Duration(seconds: 1));

      // Check user authentication status and role
      final userStatus = await _authService.getCurrentUserRole();

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (userStatus['isLoggedIn']) {
        if (userStatus['role'] == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin-dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        // Not logged in, show onboarding
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnBoardingScreen()),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      // On error, redirect to onboarding/login
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnBoardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/logo.png',
                    height: 120,
                    width: 120,
                  ),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(),
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
