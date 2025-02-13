import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/authentication/login.dart';
import '../widgets/custom_text.dart';
import '../constants/style.dart';
import '../helpers/responsiveness.dart';

// Global key for navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Function to get current user data
Future<User?> _getCurrentUser() async {
  try {
    return FirebaseAuth.instance.currentUser;
  } catch (e) {
    print("Error getting current user: $e");
    return null;
  }
}

// Function to handle logout
Future<void> logout(BuildContext context) async {
  // Sign out from Firebase
  await FirebaseAuth.instance.signOut();

  // Clear the token from shared preferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('authToken'); // Clear token
  print("Cleared token");

  // Redirect to Login screen
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => Login()), // Redirect to the login page
  );
}

// Widget to display user profile information
Widget userProfile(BuildContext context) {
  return FutureBuilder<User?>(
    future: _getCurrentUser(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator(); // Show loading indicator while fetching user
      } else if (snapshot.hasError) {
        return const CustomText(
          text: "Error loading user",
          color: Colors.white,
        );
      } else if (snapshot.hasData) {
        User? user = snapshot.data;
        return CustomText(
          text: user?.displayName ?? 'Unknown User', // Display the user's name or fallback to "Unknown User"
          color: Colors.white,
        );
      } else {
        return const CustomText(
          text: "No user found",
          color: Colors.white,
        );
      }
    },
  );
}

// The top navigation bar widget
AppBar topNavigationBar(BuildContext context, GlobalKey<ScaffoldState> key) {
  return AppBar(
    leading: !ResponsiveWidget.isSmallScreen(context)
        ? Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Image.asset(
                  "assets/icons/logo.png",
                  width: 28,
                ),
              ),
            ],
          )
        : IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              key.currentState?.openDrawer();
            }),
    title: Row(
      children: [
        Visibility(
          visible: !ResponsiveWidget.isSmallScreen(context),
          child: const CustomText(
            text: "TourMate",
            color: lightGrey,
            size: 20,
            weight: FontWeight.bold,
          ),
        ),
        Expanded(child: Container()),
        IconButton(
            icon: const Icon(
              Icons.settings,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            onPressed: () {}),
        Stack(
          children: [
            IconButton(
                icon: Icon(
                  Icons.notifications,
                  color: const Color.fromARGB(255, 255, 255, 255).withOpacity(.7),
                ),
                onPressed: () {}),
            Positioned(
              top: 7,
              right: 7,
              child: Container(
                width: 12,
                height: 12,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: active,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: light, width: 2)),
              ),
            )
          ],
        ),
        Container(
          width: 1,
          height: 22,
          color: lightGrey,
        ),
        const SizedBox(
          width: 19,
        ),
        userProfile(context), // Display user profile here
        const SizedBox(
          width: 9,
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'logout') {
              logout(context); // Call logout function when logout is selected
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline, color: Colors.black),
                  const SizedBox(width: 10),
                  const Text('Profile'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.black),
                  const SizedBox(width: 10),
                  const Text('Logout'),
                ],
              ),
            ),
          ],
          child: Container(
            decoration: BoxDecoration(
              color: active.withOpacity(.5),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(1),
              margin: const EdgeInsets.all(2),
              child: const CircleAvatar(
                backgroundColor: light,
                child: Icon(
                  Icons.person_outline,
                  color: Color.fromARGB(255, 100, 99, 99),
                ),
              ),
            ),
          ),
        )
      ],
    ),
    iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
    elevation: 0,
    backgroundColor: Colors.blue,
  );
}
