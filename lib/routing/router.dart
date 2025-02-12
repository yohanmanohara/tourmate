import 'package:flutter/material.dart';
import '../pages/authentication/login.dart';
import '../routing/routes.dart';
import '../pages/overview/overview.dart';
import '../pages/camera/camera.dart';

import '../pages/AR/ar_call.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case overviewPageRoute:
      return _getPageRoute(Ar_call());

    case arPageRoute:
      return _getPageRoute(Ar_call());

    case clientsPageRoute:
      return _getPageRoute(Ar_call());
    default:
      return _getPageRoute(Ar_call());
  }
}

PageRoute _getPageRoute(Widget child) {
  return MaterialPageRoute(builder: (context) => child);
}
