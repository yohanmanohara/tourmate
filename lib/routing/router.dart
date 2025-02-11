import 'package:flutter/material.dart';
import '../pages/authentication/login.dart';
import '../routing/routes.dart';
import '../pages/overview/overview.dart';
import '../pages/camera/camera.dart';
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case overviewPageRoute:
      return _getPageRoute(Login());
    case driversPageRoute:
      return _getPageRoute(CameraView());
    case clientsPageRoute:
      return _getPageRoute(Login());
    default:
      return _getPageRoute(Login());
  }
}

PageRoute _getPageRoute(Widget child) {
  return MaterialPageRoute(builder: (context) => child);
}
