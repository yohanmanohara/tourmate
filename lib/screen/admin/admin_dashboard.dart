import 'package:flutter/material.dart';
import '../../services/auth_services.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive layout
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;
    final double horizontalPadding = isSmallScreen ? 12.0 : 16.0;

    // Sample data - in a real app, fetch these from Firestore.
    final int totalDestinations = 25;
    final int totalUsers = 10;
    final int totalReviews = 40;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
        backgroundColor: Colors.indigoAccent,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              // Show notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await AuthService().signOut(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: isSmallScreen ? 12.0 : 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Admin Overview Header
                const Text(
                  'Dashboard Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Dashboard statistics cards - Made more responsive
                Wrap(
                  spacing: isSmallScreen ? 6 : 8,
                  runSpacing: isSmallScreen ? 6 : 8,
                  alignment: WrapAlignment.spaceEvenly,
                  children: [
                    _buildDashboardCard('Destinations', totalDestinations,
                        Icons.map, Colors.blueAccent, screenSize),
                    _buildDashboardCard('Users', totalUsers, Icons.people,
                        Colors.indigoAccent, screenSize),
                    _buildDashboardCard('Reviews', totalReviews, Icons.star,
                        Colors.orangeAccent, screenSize),
                  ],
                ),

                SizedBox(height: isSmallScreen ? 16 : 24),

                // Admin Actions Header
                const Text(
                  'Management Options',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Navigation ListTiles in a Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildListTile(
                          context,
                          'Manage Destinations',
                          Icons.map,
                          Colors.blueAccent,
                          '/manage-destinations',
                          isSmallScreen),
                      const Divider(),
                      _buildListTile(context, 'Manage Users', Icons.people,
                          Colors.indigoAccent, '/manage-users', isSmallScreen),
                      const Divider(),
                      _buildListTile(
                          context,
                          'Manage Reviews',
                          Icons.star,
                          Colors.orangeAccent,
                          '/manage-reviews',
                          isSmallScreen),
                    ],
                  ),
                ),

                SizedBox(height: isSmallScreen ? 16 : 20),

                // Quick Actions Section
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Responsive GridView for quick actions
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: screenSize.width < 480 ? 3 : 4,
                  childAspectRatio: isSmallScreen ? 0.9 : 1.0,
                  mainAxisSpacing: isSmallScreen ? 8 : 12,
                  crossAxisSpacing: isSmallScreen ? 8 : 12,
                  children: [
                    _buildActionButton(Icons.add_location, 'Add Destination',
                        Colors.blueAccent, isSmallScreen),
                    _buildActionButton(Icons.person_add, 'Add User',
                        Colors.indigoAccent, isSmallScreen),
                    _buildActionButton(Icons.analytics, 'Analytics',
                        Colors.purpleAccent, isSmallScreen),
                    _buildActionButton(
                        Icons.settings, 'Settings', Colors.grey, isSmallScreen),
                    _buildActionButton(
                        Icons.help_outline, 'Help', Colors.teal, isSmallScreen),
                    _buildActionButton(Icons.logout, 'Logout', Colors.redAccent,
                        isSmallScreen),
                  ],
                ),

                // Responsive bottom padding
                SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
              ],
            ),
          ),
        ),
      ),

      // Enhanced Bottom Navigation Bar
      bottomNavigationBar: BottomAppBar(
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
              Expanded(
                  child: _buildNavBarItem(
                      0, Icons.dashboard, 'Dashboard', isSmallScreen)),
              Expanded(
                  child:
                      _buildNavBarItem(1, Icons.map, 'Places', isSmallScreen)),
              // Larger space for FAB on smaller screens
              SizedBox(width: isSmallScreen ? 40 : 30),
              Expanded(
                  child: _buildNavBarItem(
                      2, Icons.people, 'Users', isSmallScreen)),
              Expanded(
                  child: _buildNavBarItem(
                      3, Icons.account_circle, 'Profile', isSmallScreen)),
            ],
          ),
        ),
      ),

      // Responsive floating action button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to analytics or add new content
          Navigator.pushNamed(context, '/analytics');
        },
        backgroundColor: Colors.indigoAccent,
        elevation: 4,
        // Adjust the size for smaller screens
        mini: isSmallScreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // Enhanced list tile for better responsiveness
  Widget _buildListTile(BuildContext context, String title, IconData icon,
      Color color, String route, bool isSmall) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isSmall ? 12 : 16,
        vertical: isSmall ? 2 : 4,
      ),
      leading: Icon(icon, color: color, size: isSmall ? 22 : 24),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: isSmall ? 14 : 16,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: isSmall ? 14 : 16,
      ),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }

  // Enhanced navbar item for better responsiveness
  Widget _buildNavBarItem(
      int index, IconData icon, String label, bool isSmall) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });

        // Handle navigation based on selected index
        switch (index) {
          case 0: // Dashboard - already there
            break;
          case 1: // Places Management
            Navigator.pushNamed(context, '/manage-destinations');
            break;
          case 2: // Users Management
            Navigator.pushNamed(context, '/manage-users');
            break;
          case 3: // Admin Profile
            Navigator.pushNamed(context, '/admin-profile');
            break;
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 8 : 12, vertical: isSmall ? 4 : 6),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.indigo.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.indigoAccent : Colors.grey,
              size: isSmall ? 20 : 24,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: isSmall ? 10 : 12,
                color: isSelected ? Colors.indigoAccent : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced dashboard card for better responsiveness
  Widget _buildDashboardCard(
      String title, int count, IconData icon, Color color, Size screenSize) {
    final bool isSmall = screenSize.width < 360;
    final double cardWidth = isSmall ? 85 : (screenSize.width < 400 ? 95 : 110);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: cardWidth,
        height: isSmall ? 85 : 95,
        padding: EdgeInsets.all(isSmall ? 6 : 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: isSmall ? 20 : 24),
            SizedBox(height: isSmall ? 2 : 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: isSmall ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                  fontWeight: FontWeight.w500, fontSize: isSmall ? 10 : 12),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced action button for better responsiveness
  Widget _buildActionButton(
      IconData icon, String title, Color color, bool isSmall) {
    return Column(
      children: [
        CircleAvatar(
          radius: isSmall ? 24 : 28,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white, size: isSmall ? 22 : 28),
        ),
        SizedBox(height: isSmall ? 3 : 5),
        Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: isSmall ? 10 : 12),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
