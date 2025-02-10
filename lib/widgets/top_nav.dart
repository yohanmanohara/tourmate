import 'package:flutter/material.dart';
import '../constants/style.dart';
import '../helpers/responsiveness.dart';

// import 'custom_text.dart';

AppBar topNavigationBar(BuildContext context, GlobalKey<ScaffoldState> key) =>
    AppBar(
     leading: !ResponsiveWidget.isSmallScreen(context)
    ? ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 56), // Limit width
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Image.asset(
            "assets/icons/logo.png",
            width: 28,
          ),
        ),
      )
    : IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          key.currentState?.openDrawer();
        },
      ),

    );

