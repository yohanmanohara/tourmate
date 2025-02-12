import 'package:mobileappdev/widgets/side_menu.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../services/firebase_options.dart';
import './layout.dart';
import '../controllers/menu_controller.dart' as menu_controller;
import '../controllers/navigation_controller.dart';
import 'package:get/get.dart';
import 'routing/routes.dart';


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