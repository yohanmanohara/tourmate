import 'package:flutter/material.dart';
import '../screen//profile_page.dart';
class BeautifulAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  final List<String> titles;

  const BeautifulAppBar({
    super.key,
    required this.currentIndex,
    required this.titles,
  });

  @override
  Widget build(BuildContext context) {
    return
   AppBar(
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
    IconButton(
      icon: Icon(Icons.person_outline, color: Colors.white),
      onPressed: () {
        // Navigate to the profile screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
      },
    ),
  ],
);
  }
  
    @override
    Size get preferredSize => Size.fromHeight(kToolbarHeight); // Standard AppBar height
  }
