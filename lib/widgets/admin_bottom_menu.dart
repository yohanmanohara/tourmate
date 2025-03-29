import 'package:flutter/material.dart';

class AdminBottomMenu extends StatelessWidget {
  final int currentIndex;
  final Function(int) onIndexChanged;

  const AdminBottomMenu({
    Key? key,
    required this.currentIndex,
    required this.onIndexChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 360;
    final Color primaryIndigo = Colors.indigo;

    return BottomAppBar(
      color: Colors.white,
      elevation: 8,
      notchMargin: 6,
      shape: const CircularNotchedRectangle(),
      child: Container(
        height: isSmallScreen ? 50 : 60,
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 5 : 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavBarItem(
                0, Icons.dashboard, 'Dashboard', primaryIndigo, isSmallScreen),
            _buildNavBarItem(
                1, Icons.map, 'Destinations', primaryIndigo, isSmallScreen),
            // Space for FAB
            SizedBox(width: isSmallScreen ? 40 : 30),
            _buildNavBarItem(
                2, Icons.people, 'Users', primaryIndigo, isSmallScreen),
            _buildNavBarItem(
                3, Icons.analytics, 'Analytics', primaryIndigo, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(int index, IconData icon, String label,
      Color primaryIndigo, bool isSmall) {
    bool isSelected = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => onIndexChanged(index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 8 : 12, vertical: isSmall ? 4 : 6),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryIndigo.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? primaryIndigo : Colors.grey,
                size: isSmall ? 20 : 24,
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: isSmall ? 10 : 12,
                  color: isSelected ? primaryIndigo : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
