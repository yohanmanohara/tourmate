// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import './login.dart';
import '../../services/auth_services.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import 'main_layout.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController _emailsignupController = TextEditingController();
  final TextEditingController _passwordsignupController =
      TextEditingController();
  final TextEditingController _confirmPasswordsignupController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Container(
          width: isMobile ? 300 : 400,
          height: 580, // Increased height for the name field
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                spreadRadius: 2,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset('assets/icons/logo.png', height: 60),
                    const SizedBox(width: 10),
                    Text(
                      'TourMate',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Create an Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),

                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Full Name',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    prefixIcon:
                        Icon(Icons.person_outline, color: Colors.grey.shade600),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                  ),
                ),
                const SizedBox(height: 10),

                // Email field
                TextFormField(
                  controller: _emailsignupController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    prefixIcon:
                        Icon(Icons.email_outlined, color: Colors.grey.shade600),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                  ),
                ),
                const SizedBox(height: 10),

                // Password field
                TextFormField(
                  obscureText: true,
                  controller: _passwordsignupController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    prefixIcon:
                        Icon(Icons.lock_outline, color: Colors.grey.shade600),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                  ),
                ),
                const SizedBox(height: 10),

                // Confirm Password field
                TextFormField(
                  obscureText: true,
                  controller: _confirmPasswordsignupController,
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    prefixIcon:
                        Icon(Icons.lock_outline, color: Colors.grey.shade600),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordsignupController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Signup Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Passwords do not match')),
                              );
                              return;
                            }

                            try {
                              // Register with Firebase Authentication
                              final userCredential = await _authService
                                  .createUserWithEmailAndPassword(
                                email: _emailsignupController.text,
                                password: _passwordsignupController.text,
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
                                await _firestoreService.createUser(newUser);

                                // Store user session
                                await _authService.storeUserSession(
                                    userCredential.user!, 'user');

                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Account created successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );

                                // Navigate to home page after successful signup
                                Navigator.pushReplacementNamed(
                                    context, '/home');
                              }
                            } catch (e) {
                              // Show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error creating account: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } finally {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            'Signup',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 9),

                // Google Sign Up Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });

                      try {
                        final user =
                            await _authService.signInWithGoogle(context);

                        if (user != null) {
                          // Check if user already exists in Firestore
                          final existingUser =
                              await _firestoreService.getUserData(user.uid);

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
                            Navigator.pushReplacementNamed(context, '/home');
                          }
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error signing in with Google: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/google.png', height: 24),
                        const SizedBox(width: 10),
                        const Text(
                          'Sign Up with Google',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.black87),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      },
                      child: Text(
                        ' Login',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
