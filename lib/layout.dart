import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobileappdev/widgets/top_nav.dart';
import './helpers/responsiveness.dart';
import 'package:mobileappdev/widgets/large_screen.dart';
import 'package:mobileappdev/widgets/side_menu.dart';
import '../helpers/local_navigator.dart';
import 'package:mobileappdev/pages/authentication/login.dart';
class SiteLayout extends StatefulWidget {
  const SiteLayout({super.key});

  @override
  _SiteLayoutState createState() => _SiteLayoutState();
}

class _SiteLayoutState extends State<SiteLayout> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token == null || token.isEmpty) {
      // Redirect to login if token is missing
      Future.microtask(() {
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: topNavigationBar(context, scaffoldKey),
      drawer: const Drawer(
        child: SideMenu(),
      ),
      body: ResponsiveWidget(
        largeScreen: const LargeScreen(),
        smallScreen: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: localNavigator(),
        ),
      ),
    );
  }
}
