import 'package:mobileappdev/layout.dart';
import 'package:mobileappdev/pages/authentication/login.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../services/firebase_options.dart';
import '../controllers/menu_controller.dart' as menu_controller;
import '../controllers/navigation_controller.dart';
import 'package:get/get.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main () async {
   Get.put(menu_controller.MenuController());
  Get.put(NavigationController());
  WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  SiteLayout(), 
    );
  }
}

Future<void> checkLoginStatus(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('authToken');

  if (token != null && token.isNotEmpty) {
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (context) => SiteLayout()),
    );
  }
}


