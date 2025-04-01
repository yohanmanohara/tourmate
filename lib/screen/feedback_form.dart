import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toastification/toastification.dart';
import '../services/email_service.dart';
// import 'dart:math' as math;

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({super.key});

  @override
  _FeedbackFormState createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm>
    with SingleTickerProviderStateMixin {
  static const Color primaryIndigo = Color(0xFF536DFE);
  static const Color accentIndigo = Color(0xFF536DFE);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;

  bool _isLoading = false;
  String _feedbackType = 'Bug Report';
  final List<String> _feedbackTypes = [
    'Bug Report',
    'Feature Request',
    'General Feedback',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // Animation setup
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Create staggered animations for form elements
    _fadeAnimations = List.generate(5, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1, // staggered start times
            index * 0.1 + 0.5, // staggered end times
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    _animationController.forward();
  }

  Future<void> _loadUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _nameController.text = user.displayName ?? '';
        _emailController.text = user.email ?? '';
      });
    }
  }

  Future<void> _submitFeedback() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final EmailService emailService = EmailService();

        final Map<String, String> emailData = {
          'name': _nameController.text,
          'email': _emailController.text,
          'subject': '[${_feedbackType}] ${_subjectController.text}',
          'message': _messageController.text,
          'type': _feedbackType,
        };

        await emailService.sendFeedbackEmail(emailData);

        if (mounted) {
          _showSuccessToast('Feedback sent successfully!');

          // Clear form fields
          _subjectController.clear();
          _messageController.clear();

          // Return to previous screen after short delay
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pop(context);
          });
        }
      } catch (e) {
        _showErrorToast('Error sending feedback: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showSuccessToast(String message) {
    toastification.show(
      context: context,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      alignment: Alignment.topCenter,
      backgroundColor: Colors.green.withOpacity(0.8),
      primaryColor: Colors.green,
      borderRadius: BorderRadius.circular(12),
    );
  }

  void _showErrorToast(String message) {
    toastification.show(
      context: context,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      alignment: Alignment.topCenter,
      backgroundColor: Colors.red.withOpacity(0.8),
      primaryColor: Colors.red,
      borderRadius: BorderRadius.circular(12),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'feedbackForm',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Send Feedback'),
          backgroundColor: primaryIndigo,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
        body: Stack(
          children: [
            // Background design element
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: primaryIndigo.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: accentIndigo.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(75),
                ),
              ),
            ),

            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      FadeTransition(
                        opacity: _fadeAnimations[0],
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, -0.2),
                            end: Offset.zero,
                          ).animate(_fadeAnimations[0]),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: accentIndigo.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.feedback_outlined,
                                        color: accentIndigo,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Expanded(
                                      child: Text(
                                        'We value your feedback!',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: accentIndigo,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Your suggestions help us improve TourMate. Please share your thoughts with us.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Feedback Type Dropdown
                      FadeTransition(
                        opacity: _fadeAnimations[1],
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.2),
                            end: Offset.zero,
                          ).animate(_fadeAnimations[1]),
                          child: _buildDropdown(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name Field
                      FadeTransition(
                        opacity: _fadeAnimations[2],
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.2),
                            end: Offset.zero,
                          ).animate(_fadeAnimations[2]),
                          child: _buildTextField(
                            controller: _nameController,
                            label: 'Your Name',
                            icon: Icons.person,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      FadeTransition(
                        opacity: _fadeAnimations[2],
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.2),
                            end: Offset.zero,
                          ).animate(_fadeAnimations[2]),
                          child: _buildTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Subject Field
                      FadeTransition(
                        opacity: _fadeAnimations[3],
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.2),
                            end: Offset.zero,
                          ).animate(_fadeAnimations[3]),
                          child: _buildTextField(
                            controller: _subjectController,
                            label: 'Subject',
                            icon: Icons.subject,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a subject';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Message Field
                      FadeTransition(
                        opacity: _fadeAnimations[3],
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.2),
                            end: Offset.zero,
                          ).animate(_fadeAnimations[3]),
                          child: _buildTextField(
                            controller: _messageController,
                            label: 'Message',
                            icon: Icons.message,
                            maxLines: 5,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your message';
                              }
                              if (value.length < 10) {
                                return 'Message should be at least 10 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Submit Button
                      FadeTransition(
                        opacity: _fadeAnimations[4],
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.2),
                            end: Offset.zero,
                          ).animate(_fadeAnimations[4]),
                          child: SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(
                                    begin: 1.0, end: _isLoading ? 0.95 : 1.0),
                                duration: const Duration(milliseconds: 200),
                                builder: (context, scale, child) {
                                  return Transform.scale(
                                    scale: scale,
                                    child: ElevatedButton(
                                      onPressed:
                                          _isLoading ? null : _submitFeedback,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: accentIndigo,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        elevation: 5,
                                      ),
                                      child: _isLoading
                                          ? const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Text('Sending...'),
                                              ],
                                            )
                                          : const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Submit Feedback',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Icon(Icons.send, size: 18),
                                              ],
                                            ),
                                    ),
                                  );
                                }),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.07),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: accentIndigo),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentIndigo, width: 2.0),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.07),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _feedbackType,
        decoration: InputDecoration(
          labelText: 'Feedback Type',
          prefixIcon: Icon(Icons.category, color: accentIndigo),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentIndigo, width: 2.0),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: _feedbackTypes.map((type) {
          return DropdownMenuItem(value: type, child: Text(type));
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _feedbackType = value;
            });
          }
        },
      ),
    );
  }
}
