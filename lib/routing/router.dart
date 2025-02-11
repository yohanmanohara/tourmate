import 'package:flutter/material.dart';
import '../pages/authentication/login.dart';
import '../routing/routes.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case overviewPageRoute:
      return _getPageRoute(Login());
    case driversPageRoute:
      return _getPageRoute(
        Login()
      );
    case clientsPageRoute:
      // return _getPageRoute(const ClientsPage());
    default:
      return _getPageRoute(Login());
  }
}

PageRoute _getPageRoute(Widget child) {
  return MaterialPageRoute(builder: (context) => child);
}
