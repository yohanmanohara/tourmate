import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_services.dart';
import '../../services/firestore_service.dart';
import '../../widgets/admin_bottom_menu.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;

  // Statistics variables
  Map<String, dynamic> _stats = {
    'totalDestinations': 0,
    'totalUsers': 0,
    'totalReviews': 0,
    'adminCount': 0,
    'regularUserCount': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get user statistics
      final userStats = await _firestoreService.getUserStatistics();

      // Get destination count
      final destinationsSnapshot = await FirebaseFirestore.instance
          .collection('destinations')
          .count()
          .get();

      // Get reviews count (assuming you have a reviews collection)
      final reviewsSnapshot =
          await FirebaseFirestore.instance.collection('reviews').count().get();

      setState(() {
        _stats = {
          'totalDestinations': destinationsSnapshot.count,
          'totalUsers': userStats['totalUsers'],
          'totalReviews': reviewsSnapshot.count,
          'adminCount': userStats['adminCount'],
          'regularUserCount': userStats['regularUserCount'],
        };
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading statistics: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive layout
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;
    final double horizontalPadding = isSmallScreen ? 12.0 : 16.0;

    // Define the primary indigo color to match manage destinations screen
    final Color primaryIndigo = Colors.indigo;

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
        backgroundColor: primaryIndigo,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh statistics',
            onPressed: _loadStatistics,
          ),
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
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryIndigo),
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: isSmallScreen ? 12.0 : 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Admin Overview Header with refresh indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Dashboard Overview',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          // Last updated info
                          Text(
                            'Last updated: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Dashboard statistics cards - Now using real data with indigo color
                      Wrap(
                        spacing: isSmallScreen ? 6 : 8,
                        runSpacing: isSmallScreen ? 6 : 8,
                        alignment: WrapAlignment.spaceEvenly,
                        children: [
                          _buildDashboardCard(
                              'Destinations',
                              _stats['totalDestinations'],
                              Icons.map,
                              primaryIndigo,
                              screenSize),
                          _buildDashboardCard('Users', _stats['totalUsers'],
                              Icons.people, primaryIndigo, screenSize),
                          _buildDashboardCard('Reviews', _stats['totalReviews'],
                              Icons.star, Colors.orangeAccent, screenSize),
                        ],
                      ),

                      // Additional Statistics - User breakdown with percentage
                      SizedBox(height: isSmallScreen ? 16 : 20),
                      const Text(
                        'User Statistics',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      // Users breakdown
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Users',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    '${_stats['totalUsers']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Progress indicators for user types
                              _buildUserTypeIndicator(
                                'Admin Users',
                                _stats['adminCount'],
                                _stats['totalUsers'],
                                primaryIndigo,
                              ),
                              const SizedBox(height: 12),
                              _buildUserTypeIndicator(
                                'Regular Users',
                                _stats['regularUserCount'],
                                _stats['totalUsers'],
                                Colors.greenAccent[700]!,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 16 : 24),

                      // Admin Actions Header
                      const Text(
                        'Management Options',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
                                '${_stats['totalDestinations']} destinations',
                                Icons.map,
                                primaryIndigo,
                                '/manage-destinations',
                                isSmallScreen),
                            const Divider(),
                            _buildListTile(
                                context,
                                'Manage Users',
                                '${_stats['totalUsers']} users',
                                Icons.people,
                                primaryIndigo,
                                '/manage-users',
                                isSmallScreen),
                            const Divider(),
                            _buildListTile(
                                context,
                                'Manage Reviews',
                                '${_stats['totalReviews']} reviews',
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
                          _buildActionButton(
                            Icons.add_location,
                            'Add Destination',
                            primaryIndigo,
                            isSmallScreen,
                            onTap: () => Navigator.pushNamed(
                                context, '/edit-destination'),
                          ),
                          _buildActionButton(
                            Icons.person_add,
                            'Add User',
                            primaryIndigo,
                            isSmallScreen,
                            onTap: () =>
                                Navigator.pushNamed(context, '/manage-users'),
                          ),
                          _buildActionButton(Icons.analytics, 'Analytics',
                              Colors.purpleAccent, isSmallScreen),
                          _buildActionButton(Icons.settings, 'Settings',
                              Colors.grey, isSmallScreen),
                          _buildActionButton(Icons.help_outline, 'Help',
                              Colors.teal, isSmallScreen),
                          _buildActionButton(
                            Icons.logout,
                            'Logout',
                            Colors.redAccent,
                            isSmallScreen,
                            onTap: () async {
                              await AuthService().signOut(context);
                            },
                          ),
                        ],
                      ),

                      // Responsive bottom padding
                      SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 80),
                    ],
                  ),
                ),
              ),
      ),

      // Replace existing bottomNavigationBar with our new component
      bottomNavigationBar: AdminBottomMenu(
        currentIndex: _selectedIndex,
        onIndexChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });

          // Handle navigation based on selected index
          switch (index) {
            case 0: // Already on Dashboard
              break;
            case 1: // Destinations
              Navigator.pushReplacementNamed(context, '/manage-destinations');
              break;
            case 2: // Users
              Navigator.pushReplacementNamed(context, '/manage-users');
              break;
            case 3: // Analytics
              Navigator.pushReplacementNamed(context, '/analytics');
              break;
          }
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action varies based on current screen
          if (_selectedIndex == 1) {
            Navigator.pushNamed(context, '/edit-destination');
          } else if (_selectedIndex == 2) {
            Navigator.pushNamed(context, '/add-user');
          } else {
            Navigator.pushNamed(context, '/analytics');
          }
        },
        backgroundColor: primaryIndigo,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add New',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // Enhanced list tile for better responsiveness
  Widget _buildListTile(BuildContext context, String title, String subtitle,
      IconData icon, Color color, String route, bool isSmall) {
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
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: isSmall ? 10 : 12,
          color: Colors.grey[600],
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

  // Enhanced navbar item for better responsiveness with indigo color
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
              color: isSelected ? Colors.indigo : Colors.grey,
              size: isSmall ? 20 : 24,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: isSmall ? 10 : 12,
                color: isSelected ? Colors.indigo : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced dashboard card for better responsiveness with updated color
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
      IconData icon, String title, Color color, bool isSmall,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
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
      ),
    );
  }

  // User type indicator with progress bar
  Widget _buildUserTypeIndicator(
      String label, int count, int total, Color color) {
    final double percentage = (total > 0) ? (count / total) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: $count',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}
