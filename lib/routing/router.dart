import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routing/routes.dart';
import '../pages/authentication/login.dart';
import '../pages/overview/overview.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case overviewPageRoute:
      return _getPageRoute(Overview());
    

    default:
     return _getPageRoute(Overview()); 
     
     }
}

PageRoute _getPageRoute(Widget child) {
  return MaterialPageRoute(builder: (context) => child);
}
