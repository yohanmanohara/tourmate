import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceScreen extends StatefulWidget {
  const PreferenceScreen({super.key});

  @override
  _PreferenceScreenState createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  final List<String> categories = [
    'Historical',
    'Nature',
    'Cultural',
    'Urban',
    'Adventure',
    'Food',
    'Beach',
    'Mountain',
    'Religious',
    'Art'
  ];

  final Set<String> selectedCategories = {};
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkExistingPreferences();
  }

  Future<void> _checkExistingPreferences() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Check if preferences already exist in Firestore
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          if (userData != null && userData.containsKey('preferences')) {
            final List<dynamic> prefs = userData['preferences'];
            setState(() {
              selectedCategories.addAll(prefs.cast<String>());
            });
          }
        }
      } catch (e) {
        print('Error loading preferences: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _savePreferences() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You need to be logged in to save preferences')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if user document exists first
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        // Create user document if it doesn't exist
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Save to Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'preferences': selectedCategories.toList(),
      });

      // Save to SharedPreferences for quick local access
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('userPreferences', selectedCategories.toList());

      // Mark that user has completed onboarding
      await prefs.setBool('hasCompletedPreferences', true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences saved successfully!')),
        );

        // Navigate to home screen
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print('Error saving preferences: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to save preferences: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF007AFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // App logo or icon
                      Align(
                        alignment: Alignment.topLeft,
                        child: Image.asset(
                          'assets/images/tourmate_logo_white.png',
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Title
                      const Text(
                        'What places do you love to visit?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 10),

                      // Subtitle
                      const Text(
                        'Select at least 3 categories to personalize your experience',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 30),

                      // Categories (Dynamically Positioned)
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 15,
                            alignment: WrapAlignment.center,
                            children: categories
                                .map((category) =>
                                    _buildCategoryButton(category))
                                .toList(),
                          ),
                        ),
                      ),

                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          onPressed: selectedCategories.length >= 3
                              ? _savePreferences
                              : null,
                          child: Text(
                            selectedCategories.length >= 3
                                ? 'Continue'
                                : 'Select at least ${3 - selectedCategories.length} more',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: selectedCategories.length >= 3
                                  ? Colors.blueAccent
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),

                      // Skip for now option
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        child: const Text(
                          'Skip for now',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // Beautiful Category Button Widget
  Widget _buildCategoryButton(String category) {
    final isSelected = selectedCategories.contains(category);
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected
              ? selectedCategories.remove(category)
              : selectedCategories.add(category);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
          border: Border.all(color: Colors.white, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getCategoryIcon(category),
              color: isSelected ? Colors.blueAccent : Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              category,
              style: TextStyle(
                color: isSelected ? Colors.blueAccent : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Get appropriate icon for each category
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Historical':
        return Icons.history_edu;
      case 'Nature':
        return Icons.landscape;
      case 'Cultural':
        return Icons.theater_comedy;
      case 'Urban':
        return Icons.location_city;
      case 'Adventure':
        return Icons.terrain;
      case 'Food':
        return Icons.restaurant;
      case 'Beach':
        return Icons.beach_access;
      // case 'Mountain':
      //   return Icons.mountain_biking;
      case 'Religious':
        return Icons.temple_buddhist;
      case 'Art':
        return Icons.palette;
      default:
        return Icons.place;
    }
  }
}
