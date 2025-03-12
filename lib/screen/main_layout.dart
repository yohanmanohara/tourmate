import 'package:flutter/material.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import '../widgets/appbar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomePage(),
    ProfilePage(),
    SettingsPage(),
  ];

  final List<String> _titles = [
    'Home',
    'Profile',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom AppBar
      appBar: BeautifulAppBar(
        currentIndex: _currentIndex,
        titles: _titles,
      ),
      
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),

      // Bottom Navigation Bar with Custom Camera Button
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.deepPurpleAccent, // Selected item color
        unselectedItemColor: Colors.grey, // Unselected item color
        backgroundColor: Colors.white, // Background color
        type: BottomNavigationBarType.fixed, // Fixed type for a modern look
        elevation: 20, // Increased elevation for a stronger shadow
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        selectedIconTheme: IconThemeData(
          size: 28, // Larger size for selected icons
          color: Colors.deepPurpleAccent, // Selected icon color
        ),
        unselectedIconTheme: IconThemeData(
          size: 24, // Smaller size for unselected icons
          color: Colors.grey, // Unselected icon color
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          // Custom Camera Button with Blue Background and Rounded Edges
          BottomNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                color: Colors.blue, // Blue background for Camera button
                shape: BoxShape.circle, // Rounded shape
              ),
              padding: EdgeInsets.all(12.0), // Padding to control the size
              child: Icon(
                Icons.camera_alt_outlined,
                color: Colors.white, // White icon for contrast
              ),
            ),
            label: "Camera",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
