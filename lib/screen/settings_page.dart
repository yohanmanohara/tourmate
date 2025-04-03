import 'package:flutter/material.dart';
import 'feedback_form.dart';
import '../services/auth_services.dart';
import 'profile_page.dart';
import 'dart:math' as math;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  static const Color primaryIndigo = Color(0xFF536DFE);
  static const Color accentIndigo = Color(0xFF7C4DFF);

  late AnimationController _animationController;
  final int _totalItems = 6; // Total number of animated items

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Animation<double> _getStaggeredAnimation(int index) {
    // Create staggered animations for list items
    final double start = 0.1 + (0.8 / _totalItems) * index;
    final double end = start + (0.8 / _totalItems);

    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(start, end, curve: Curves.easeOutQuint),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: primaryIndigo,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primaryIndigo,
                          accentIndigo,
                        ],
                      ),
                    ),
                  ),
                  // Design elements
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader(0, 'Account Settings'),
                const SizedBox(height: 16),
                _buildSettingTile(
                  context,
                  1,
                  'Profile',
                  'Manage your personal information',
                  Icons.person,
                  () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const ProfilePage(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          var begin = const Offset(1.0, 0.0);
                          var end = Offset.zero;
                          var curve = Curves.easeInOutCubic;
                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          return SlideTransition(
                              position: animation.drive(tween), child: child);
                        },
                      ),
                    );
                  },
                ),
                _buildSettingTile(
                  context,
                  2,
                  'Send Feedback',
                  'Help us improve TourMate',
                  Icons.feedback,
                  () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const FeedbackForm(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          var begin = const Offset(0.0, 1.0);
                          var end = Offset.zero;
                          var curve = Curves.easeOutQuint;
                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          return SlideTransition(
                              position: animation.drive(tween), child: child);
                        },
                      ),
                    );
                  },
                ),
                _buildSettingTile(
                  context,
                  3,
                  'Logout',
                  'Sign out from your account',
                  Icons.logout,
                  () async {
                    // Show confirmation dialog with improved design
                    final confirm = await showDialog<bool>(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) => AlertDialog(
                        title: const Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red),
                            SizedBox(width: 10),
                            Text('Log Out'),
                          ],
                        ),
                        content:
                            const Text('Are you sure you want to log out?'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Log Out'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await AuthService().signOut(context);
                    }
                  },
                ),
                const Divider(height: 32),
                _buildSectionHeader(4, 'App Settings'),
                const SizedBox(height: 16),
                _buildSettingTile(
                  context,
                  5,
                  'About TourMate',
                  'Version and legal information',
                  Icons.info,
                  () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/icons/logo.png',
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'TourMate',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: primaryIndigo,
                                ),
                              ),
                              const Text(
                                'Version 1.0.0',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'TourMate is a travel companion app designed for Sri Lankan tourists.',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryIndigo,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  minimumSize: const Size(double.infinity, 45),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(int index, String title) {
    return FadeTransition(
      opacity: _getStaggeredAnimation(index),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_getStaggeredAnimation(index)),
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: primaryIndigo,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryIndigo,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    int index,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return FadeTransition(
      opacity: _getStaggeredAnimation(index),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.5, 0),
          end: Offset.zero,
        ).animate(_getStaggeredAnimation(index)),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 1, end: 1),
            duration: const Duration(milliseconds: 300),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                splashColor: primaryIndigo.withOpacity(0.1),
                highlightColor: primaryIndigo.withOpacity(0.05),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.grey.shade50,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryIndigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: primaryIndigo),
                      ),
                      title: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(subtitle),
                      trailing: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.grey,
                        ),
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
}
