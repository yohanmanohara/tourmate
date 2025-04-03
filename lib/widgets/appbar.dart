import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_services.dart';
import '../screen/settings_page.dart';
import '../screen/profile_page.dart';
import 'dart:async'; 
import '../widgets/notification_page.dart';

class BeautifulAppBar extends StatefulWidget implements PreferredSizeWidget {
  final int currentIndex;
  final List<String> titles;
  final VoidCallback? onNotificationPressed;

  const BeautifulAppBar({
    super.key,
    required this.currentIndex,
    required this.titles,
    this.onNotificationPressed,
  });

  @override
  State<BeautifulAppBar> createState() => _BeautifulAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _BeautifulAppBarState extends State<BeautifulAppBar> {
  String? profileImageUrl;
  String? username;
  bool isLoading = true;
  Timer? _timer; 

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _loadUserData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            profileImageUrl = userData['photoUrl'] ?? userData['profileImageUrl'];
            username = userData['name'];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error loading user data: $e');
    }
  }

  void _onMenuItemSelected(String value) {
    switch (value) {
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsPage()),
        );
        break;
      case 'logout':
        AuthService().signOut(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, 
       iconTheme: const IconThemeData(color: Colors.white),
      // This ensures no back button appears
      title: Text(
        'TourMate',
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.indigoAccent,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: widget.onNotificationPressed ?? () {
            
            Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationPage()),
        );
          },
        ),
        Text(
          username ?? 'My Profile',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15.0,
          ),
        ),
        PopupMenuButton<String>(
          icon: CircleAvatar(
            backgroundColor: Colors.transparent,
            backgroundImage: profileImageUrl != null
                ? NetworkImage(profileImageUrl!)
                : const AssetImage('assets/icons/profile.png') as ImageProvider,
            onBackgroundImageError: (exception, stackTrace) {
              setState(() {
                profileImageUrl = null;
              });
            },
            child: profileImageUrl == null
                ? Image.asset(
                    'assets/icons/profile.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          onSelected: _onMenuItemSelected,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('Settings'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Logout'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}