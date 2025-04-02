import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_services.dart';
import '../screen/settings_page.dart';
import '../screen/profile_page.dart';
import 'dart:async'; 
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
  String?username;
  bool isLoading = true;
    Timer? _timer; // A

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _timer = Timer.periodic(const Duration(minutes: 3), (timer) {
      _loadUserData();
    });
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
            username=userData['name'];
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
      title: Text(
        widget.titles[widget.currentIndex],
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.indigoAccent,
      elevation: 4,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: widget.onNotificationPressed ?? () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No new notifications')),
            );
          },
        ),
 Text(
  username ?? 'My Profile',
  style: const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,  // Makes text bold
    fontSize: 15.0,              // Slightly larger size
  ),
),


        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
        else


          PopupMenuButton<String>(
            icon: CircleAvatar(
    backgroundColor: Colors.white, // Background when no image
    backgroundImage: profileImageUrl != null 
        ? NetworkImage(profileImageUrl!) 
        : null,
    onBackgroundImageError: (exception, stackTrace) {
      setState(() {
        profileImageUrl = null;
      });
    },
    child: profileImageUrl == null
        ? const Icon(
            Icons.person_outline,
            color: Colors.indigoAccent,
            size: 18,
          )
        : ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcATop,
            ),
            child: Container(), // Empty container as the image is already set as background
          ),
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