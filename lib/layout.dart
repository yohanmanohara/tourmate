import 'package:flutter/material.dart';
import 'package:mobileappdev/widgets/top_nav.dart';
import './helpers/responsiveness.dart';
import 'package:mobileappdev/widgets/large_screen.dart';
import 'package:mobileappdev/widgets/side_menu.dart';
import '../helpers/local_navigator.dart';
class SiteLayout extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  SiteLayout({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      // extendBodyBehindAppBar: true,
      appBar:  topNavigationBar(context, scaffoldKey),
      drawer: const Drawer(
        child: SideMenu(),
      ),
      body: ResponsiveWidget(
        largeScreen: const LargeScreen(),
        smallScreen: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: localNavigator(),
      )
      ),
    );
  }
}
