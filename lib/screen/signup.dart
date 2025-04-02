// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import './login.dart';
import '../../services/auth_services.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> with SingleTickerProviderStateMixin {
  final TextEditingController _emailsignupController = TextEditingController();
  final TextEditingController _passwordsignupController =
      TextEditingController();
  final TextEditingController _confirmPasswordsignupController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  // Add animation controllers to match login screen
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuart,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailsignupController.dispose();
    _passwordsignupController.dispose();
    _confirmPasswordsignupController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      width: isSmallScreen ? size.width * 0.9 : 400,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo and App Name
                          Center(
                            child: Column(
                              children: [
                                Hero(
                                  tag: 'logo',
                                  child: Image.asset(
                                    'assets/icons/logo.png',
                                    height: 70,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'TourMate',
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1976D2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Create Account Text
                          Text(
                            'Create Account',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Sign up to get started',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Name Field
                          buildTextField(
                            controller: _nameController,
                            hintText: 'Full Name',
                            prefixIcon: Icons.person_outline,
                          ),
                          const SizedBox(height: 16),

                          // Email Field
                          buildTextField(
                            controller: _emailsignupController,
                            hintText: 'Email',
                            prefixIcon: Icons.email_outlined,
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          buildTextField(
                            controller: _passwordsignupController,
                            hintText: 'Password',
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password Field
                          buildTextField(
                            controller: _confirmPasswordsignupController,
                            hintText: 'Confirm Password',
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          const SizedBox(height: 24),

                          // Signup Button
                          buildElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    setState(() {
                                      _isLoading = true;
                                    });

                                    // Check if password and confirm password match
                                    if (_passwordsignupController.text !=
                                        _confirmPasswordsignupController.text) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                      // Show error message if passwords don't match
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Passwords do not match')),
                                      );
                                      return;
                                    }

                                    try {
                                      // Register with Firebase Authentication
                                      final userCredential = await _authService
                                          .createUserWithEmailAndPassword(
                                        email: _emailsignupController.text,
                                        password:
                                            _passwordsignupController.text,
                                      );

                                      if (userCredential != null &&
                                          userCredential.user != null) {
                                        // Create a UserModel object
                                        final UserModel newUser = UserModel(
                                          uid: userCredential.user!.uid,
                                          email: _emailsignupController.text,
                                          role: 'user', // Default role is user
                                          name: _nameController.text.isNotEmpty
                                              ? _nameController.text
                                              : null,
                                          photoUrl: null,
                                        );

                                        // Store user in Firestore
                                        await _firestoreService
                                            .createUser(newUser);

                                        // Store user session
                                        await _authService.storeUserSession(
                                            userCredential.user!, 'user');

                                        // Show success message
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Account created successfully!'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );

                                        // Navigate to home page after successful signup
                                        final prefs = await SharedPreferences
                                            .getInstance();
                                        bool hasCompletedPreferences =
                                            prefs.getBool(
                                                    'hasCompletedPreferences') ??
                                                false;

                                        if (hasCompletedPreferences) {
                                          Navigator.pushReplacementNamed(
                                              context, '/home');
                                        } else {
                                          Navigator.pushReplacementNamed(
                                              context, '/preferences');
                                        }
                                      }
                                    } catch (e) {
                                      // Show error message
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Error creating account: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    } finally {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  },
                            text: 'Sign Up',
                            isLoading: _isLoading,
                            isPrimary: true,
                          ),
                          const SizedBox(height: 16),

                          // Or divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.grey.shade300,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.grey.shade300,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Google Sign Up Button
                          buildElevatedButton(
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                              });

                              try {
                                final user = await _authService
                                    .signInWithGoogle(context);

                                if (user != null) {
                                  // Check if user already exists in Firestore
                                  final existingUser = await _firestoreService
                                      .getUserData(user.uid);

                                  if (existingUser == null) {
                                    // If user doesn't exist, create a new user record
                                    final newUser = UserModel(
                                      uid: user.uid,
                                      email: user.email ?? '',
                                      role: 'user',
                                      name: user.displayName,
                                      photoUrl: user.photoURL,
                                    );

                                    // Store in Firestore
                                    await _firestoreService.createUser(newUser);
                                  }

                                  // Navigate based on role
                                  final userRole = existingUser?.role ?? 'user';
                                  if (userRole == 'admin') {
                                    Navigator.pushReplacementNamed(
                                        context, '/admin-dashboard');
                                  } else {
                                    Navigator.pushReplacementNamed(
                                        context, '/home');
                                  }
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Error signing in with Google: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } finally {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            },
                            text: 'Sign up with Google',
                            icon: 'assets/google.png',
                            isPrimary: false,
                          ),
                          const SizedBox(height: 20),

                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account?',
                                style: GoogleFonts.poppins(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          const Login(),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        var begin = const Offset(-1.0, 0.0);
                                        var end = Offset.zero;
                                        var curve = Curves.ease;

                                        var tween = Tween(
                                                begin: begin, end: end)
                                            .chain(CurveTween(curve: curve));

                                        return SlideTransition(
                                          position: animation.drive(tween),
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Login',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF1976D2),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Using the same helper methods as in login screen
  Widget buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
        ),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF1976D2)),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      style: GoogleFonts.poppins(
        fontSize: 15,
        color: Colors.black87,
      ),
    );
  }

  Widget buildElevatedButton({
    required VoidCallback? onPressed,
    required String text,
    String? icon,
    bool isLoading = false,
    bool isPrimary = true,
  }) {
    final buttonColor = isPrimary ? const Color(0xFF1976D2) : Colors.white;
    final textColor = isPrimary ? Colors.white : Colors.black87;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: textColor,
          elevation: isPrimary ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(color: Colors.grey.shade300),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isPrimary ? Colors.white : const Color(0xFF1976D2),
                  ),
                  strokeWidth: 2.5,
                ),
              )
            : icon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(icon, height: 24),
                      const SizedBox(width: 12),
                      Text(
                        text,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
      ),
    );
  }
}
