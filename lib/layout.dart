import 'package:flutter/material.dart';
import 'package:mobileappdev/widgets/top_nav.dart';
import './helpers/responsiveness.dart';
import 'package:mobileappdev/widgets/large_screen.dart';
import 'package:mobileappdev/widgets/small_screen.dart';

class SiteLayout extends StatelessWidget {
   SiteLayout({super.key});
  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar:topNavigationBar(context, scaffoldkey),
      body: ResponsiveWidget(largeScreen: LargeScreen(),smallScreen: SmallScreen(),)

    );
  } 
}