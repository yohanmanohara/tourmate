import 'package:flutter/material.dart';
import '../screen/PreferenceScreen.dart';
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
      // Implement logout functionality here
      print("User logged out");
      // For example, clear session data or token, then navigate to login screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Align(
        alignment: Alignment.centerLeft, // Align title to the left
        child: Text(
          titles[currentIndex],
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: Colors.white, // Ensure text is visible
          ),
        ),
      ),
      backgroundColor: Colors.indigoAccent,
      elevation: 4,
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) => _onMenuItemSelected(value, context),
          icon: Icon(Icons.person_outline, color: Colors.white),
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, color: Colors.black),
                  SizedBox(width: 10),
                  Text("Settings"),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.exit_to_app, color: Colors.black),
                  SizedBox(width: 10),
                  Text("Logout"),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight); // Standard AppBar height
}
