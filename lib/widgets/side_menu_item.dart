import 'package:flutter/material.dart';
import '../helpers/responsiveness.dart';
import '../widgets/horizontal_menu_item.dart';
import './vertical_menu_item.dart';

class SideMenuItem extends StatelessWidget {
  final String itemName;
  final Function(
  ) onTap;

  const SideMenuItem({super.key, required this.itemName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (ResponsiveWidget.isCustomSize(context)) {
      return VertticalMenuItem(
        itemName: itemName,
        onTap: onTap,
      );
    } else {
      return HorizontalMenuItem(
        itemName: itemName,
        onTap: onTap,
      );
    }
  }
}
