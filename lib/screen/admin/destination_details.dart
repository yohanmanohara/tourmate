import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../widgets/admin_bottom_menu.dart';

class DestinationDetailsScreen extends StatefulWidget {
  final String destinationId;

  const DestinationDetailsScreen({
    Key? key,
    required this.destinationId,
  }) : super(key: key);

  @override
  State<DestinationDetailsScreen> createState() =>
      _DestinationDetailsScreenState();
}

class _DestinationDetailsScreenState extends State<DestinationDetailsScreen> {
  final int _selectedIndex = 1; // Set to 1 for Destinations tab

  void _openInGoogleMaps(double lat, double lng) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not open Google Maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define the primary indigo color to match other admin screens
    final Color primaryIndigo = Colors.indigo;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Destination Preview',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryIndigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: 'Edit destination',
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                '/edit-destination',
                arguments: widget.destinationId,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            tooltip: 'Share destination',
            onPressed: () {
              // Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Share functionality coming soon')),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('destinations')
            .doc(widget.destinationId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryIndigo),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryIndigo,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_off, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Destination not found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryIndigo,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final List<dynamic> imagesList = data['images'] ?? [];

          // Get coordinates for the map - default to center of Sri Lanka if not available
          final double latitude = data['coordinates']?['latitude'] ?? 7.8731;
          final double longitude = data['coordinates']?['longitude'] ?? 80.7718;
          final bool hasCoordinates = data['coordinates'] != null;

          return CustomScrollView(
            slivers: [
              // Image carousel
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    SizedBox(
                      height: 280,
                      child: PageView.builder(
                        itemCount: imagesList.isEmpty ? 1 : imagesList.length,
                        itemBuilder: (context, index) {
                          if (imagesList.isEmpty) {
                            return Container(
                              color: Colors.grey[200],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No images available',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Hero(
                            tag:
                                'destination-image-${widget.destinationId}-$index',
                            child: Image.network(
                              imagesList[index],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child:
                                      Icon(Icons.image_not_supported, size: 50),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Category badge overlay
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: primaryIndigo.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          data['category'] ?? 'Uncategorized',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    // Rating badge if available
                    if (data['averageRating'] != null)
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${(data['averageRating'] as num).toStringAsFixed(1)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Content area
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        data['title'] ?? 'Untitled Destination',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 22 : 26,
                          fontWeight: FontWeight.bold,
                          color: primaryIndigo,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Location with indigo color
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 18,
                            color: primaryIndigo,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              data['location'] ?? 'Location not specified',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Section heading in indigo
                      Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 20,
                            color: primaryIndigo,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryIndigo,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Description text
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          data['description'] ?? 'No description available',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Map Section Heading
                      Row(
                        children: [
                          Icon(
                            Icons.map_outlined,
                            size: 20,
                            color: primaryIndigo,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Location Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryIndigo,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Map Container
                      Container(
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              FlutterMap(
                                options: MapOptions(
                                  initialCenter: LatLng(latitude, longitude),
                                  initialZoom: 13.0,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    subdomains: const ['a', 'b', 'c'],
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      if (hasCoordinates)
                                        Marker(
                                          width: 80.0,
                                          height: 80.0,
                                          point: LatLng(latitude, longitude),
                                          child: const Icon(
                                            Icons.location_on,
                                            color: Colors.red,
                                            size: 40.0,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              // Directions button
                              if (hasCoordinates)
                                Positioned(
                                  right: 10,
                                  bottom: 10,
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _openInGoogleMaps(latitude, longitude),
                                    icon: const Icon(Icons.directions),
                                    label: const Text('Get Directions'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryIndigo,
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      if (hasCoordinates)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.gps_fixed,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Coordinates: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Features Section
                      if (data['features'] != null &&
                          (data['features'] as List).isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.star_outline,
                                  size: 20,
                                  color: primaryIndigo,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Features',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: primaryIndigo,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: (data['features'] as List)
                                  .map<Widget>((feature) {
                                return Chip(
                                  label: Text(feature),
                                  backgroundColor:
                                      primaryIndigo.withOpacity(0.1),
                                  labelStyle: TextStyle(
                                    color: primaryIndigo,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: primaryIndigo.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 0,
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),

                      const Divider(),

                      // Admin actions
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit Destination'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryIndigo,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/edit-destination',
                                    arguments: widget.destinationId,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                label: const Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.red),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text(
                                        'Delete Destination',
                                        style: TextStyle(color: primaryIndigo),
                                      ),
                                      content: const Text(
                                        'Are you sure you want to delete this destination? This action cannot be undone.',
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text('Cancel'),
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Delete'),
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed == true) {
                                    try {
                                      await FirebaseFirestore.instance
                                          .collection('destinations')
                                          .doc(widget.destinationId)
                                          .delete();

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Destination deleted successfully'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        Navigator.pop(context);
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Error deleting destination: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: AdminBottomMenu(
        currentIndex: _selectedIndex,
        onIndexChanged: (index) {
          if (index == _selectedIndex) return;

          switch (index) {
            case 0: // Dashboard
              Navigator.pushReplacementNamed(context, '/admin-dashboard');
              break;
            case 1: // Go back to all destinations
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
          Navigator.pushNamed(
            context,
            '/edit-destination',
            arguments: widget.destinationId,
          );
        },
        backgroundColor: primaryIndigo,
        child: const Icon(Icons.edit, color: Colors.white),
        tooltip: 'Edit destination',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
