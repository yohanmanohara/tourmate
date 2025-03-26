import 'package:flutter/material.dart';
import '../screen/PreferenceScreen.dart';
import '../services/auth_services.dart';

class BeautifulAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  final List<String> titles;

  const BeautifulAppBar({
    super.key,
    required this.currentIndex,
    required this.titles,
  });

  void _onMenuItemSelected(String value, BuildContext context) {
    if (value == 'settings') {
      // Navigate to settings page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PreferenceScreen()),
      );
    } else if (value == 'logout') {
      // Implement logout functionality
      AuthService().signOut(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        titles[currentIndex],
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.indigoAccent,
      elevation: 4,
      actions: [
        // Add notification icon
        IconButton(
          icon: Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {
            // Show notifications
          },
        ),

        // Add profile icon or popup menu
        PopupMenuButton<String>(
          icon: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 16,
            child: Icon(
              Icons.person_outline,
              color: Colors.indigoAccent,
              size: 18,
            ),
          ),
          onSelected: (value) => _onMenuItemSelected(value, context),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.indigoAccent),
                  SizedBox(width: 8),
                  Text('Profile'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('Settings'),
                ],
              ),
            ),
            PopupMenuItem(
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
        SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
