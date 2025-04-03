import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../services/auth_services.dart';
class Analytics extends StatefulWidget {
  const Analytics({super.key});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> with SingleTickerProviderStateMixin {
  int _selectedIndex = 3;
  final Color primaryColor = Colors.indigo; // Changed to match admin dashboard
  final Color secondaryColor = const Color(0xFF4A44B7);
  final Color backgroundColor = Colors.white;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> analyticsData = [
    {'title': 'Total Users', 'value': '16', 'change': '+32%', 'icon': Icons.people_alt_outlined, 'color': Colors.blue},
    {'title': 'Active USers Today', 'value': '5', 'change': '+24%', 'icon': Icons.trending_up, 'color': Colors.green},
    {'title': 'New Sign-ups', 'value': '2', 'change': '+2%', 'icon': Icons.person_add_alt_1, 'color': Colors.orange},
  ];

  final List<Map<String, dynamic>> chartData = [
    {'day': 'Mon', 'value': 45},
    {'day': 'Tue', 'value': 68},
    {'day': 'Wed', 'value': 72},
    
    {'day': 'Fri', 'value': 120},
   
    {'day': 'Sun', 'value': 98},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Start animation after build
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _refreshData() async {
    _animationController.reset();
    await _animationController.forward();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Data refreshed'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive layout
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Analytics Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 4,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh statistics',
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await AuthService().signOut(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Key Metrics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isSmallScreen ? 2 : 2,
                  childAspectRatio: isSmallScreen ? 1.1 : 1.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: analyticsData.length,
                itemBuilder: (context, index) => _buildMetricCard(analyticsData[index]),
              ),
              const SizedBox(height: 24),
              const Text(
                'User Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              _buildActivityChart(),
              const SizedBox(height: 24),
             
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomAppBar(isSmallScreen),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add action
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        elevation: 2,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildMetricCard(Map<String, dynamic> data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: data['color'].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    data['icon'],
                    color: data['color'],
                    size: 20,
                  ),
                ),
                Text(
                  data['change'],
                  style: TextStyle(
                    color: data['change'].startsWith('+') ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              data['title'],
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data['value'],
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityChart() {
    final maxValue = chartData.map((e) => e['value'] as int).reduce((a, b) => a > b ? a : b);
    
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chartData.map((data) {
                final height = (data['value'] / maxValue) * 100;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: height,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.7),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data['day'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Last 7 Days',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(3, (index) => _buildActivityItem(index)),
      ],
    );
  }

  Widget _buildActivityItem(int index) {
    final activities = [
      {'title': 'New user registered', 'time': '2 min ago', 'icon': Icons.person_add},
      {'title': 'Destination added', 'time': '15 min ago', 'icon': Icons.add_location},
      {'title': 'Payment received', 'time': '1 hour ago', 'icon': Icons.payment},
    ];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              activities[index]['icon'] as IconData,
              color: primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activities[index]['title'] as String,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activities[index]['time'] as String,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  BottomAppBar _buildBottomAppBar(bool isSmallScreen) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      elevation: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavBarItem(0, Icons.dashboard, 'Dashboard', isSmallScreen),
            _buildNavBarItem(1, Icons.location_on, 'Destinations', isSmallScreen),
            _buildNavBarItem(2, Icons.people, 'Users', isSmallScreen),
            _buildNavBarItem(3, Icons.analytics, 'Analytics', isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(int index, IconData icon, String label, bool isSmall) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });

        // Handle navigation based on selected index
        switch (index) {
          case 0: // Dashboard
            Navigator.pushReplacementNamed(context, '/admin-dashboard');
            break;
          case 1: // Destinations Management
            Navigator.pushReplacementNamed(context, '/manage-destinations');
            break;
          case 2: // Users Management
            Navigator.pushReplacementNamed(context, '/manage-users');
            break;
          case 3: // Analytics - already there
            break;
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 8 : 12, vertical: isSmall ? 4 : 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : Colors.grey,
              size: isSmall ? 20 : 24,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: isSmall ? 10 : 12,
                color: isSelected ? primaryColor : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}