import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ARMapScreen extends StatefulWidget {
  const ARMapScreen({Key? key}) : super(key: key);

  @override
  State<ARMapScreen> createState() => _ARMapScreenState();
}

class _ARMapScreenState extends State<ARMapScreen> {
  final MapController _mapController = MapController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _destinations = [];
  String _selectedCategoryFilter = 'All';

  // List of category filters
  final List<String> _categories = [
    'All',
    'Historical',
    'Nature',
    'Cultural',
    'Urban',
    'Adventure'
  ];

  @override
  void initState() {
    super.initState();
    _loadDestinations();
  }

  Future<void> _loadDestinations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('destinations').get();

      if (mounted) {
        setState(() {
          _destinations = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'id': doc.id,
              'title': data['title'] ?? 'Unknown Location',
              'category': data['category'] ?? 'Uncategorized',
              'description': data['description'] ?? '',
              'imageUrl':
                  data['images'] != null && (data['images'] as List).isNotEmpty
                      ? data['images'][0]
                      : null,
              'latitude': data['coordinates']?['latitude'] ?? 7.8731,
              'longitude': data['coordinates']?['longitude'] ?? 80.7718,
              'location': data['location'] ?? '',
              'rating': data['averageRating'] ?? 0.0,
              'hasCoordinates': data['coordinates'] != null,
            };
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading destinations: $e')),
        );
      }
    }
  }

  void _openInGoogleMaps(double latitude, double longitude) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not open Google Maps';
    }
  }

  void _viewDestinationDetails(String id) {
    Navigator.pushNamed(context, '/destination-details', arguments: id);
  }

  @override
  Widget build(BuildContext context) {
    // Define the primary indigo color to match other admin screens
    final Color primaryIndigo = Colors.indigo;

    // Filter destinations by selected category
    final filteredDestinations = _selectedCategoryFilter == 'All'
        ? _destinations
        : _destinations
            .where((d) => d['category'] == _selectedCategoryFilter)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Explore Destinations',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryIndigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh destinations',
            onPressed: _loadDestinations,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryIndigo),
              ),
            )
          : Column(
              children: [
                // Category filters
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _categories.map((category) {
                      final isSelected = _selectedCategoryFilter == category;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          showCheckmark: false,
                          backgroundColor: Colors.grey[100],
                          selectedColor: primaryIndigo.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? primaryIndigo : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          side: BorderSide(
                            color:
                                isSelected ? primaryIndigo : Colors.transparent,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategoryFilter =
                                  selected ? category : 'All';
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Destination count indicator
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Text(
                        '${filteredDestinations.length} ${_selectedCategoryFilter == 'All' ? 'destinations' : _selectedCategoryFilter.toLowerCase() + ' destinations'} found',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.map, size: 16, color: primaryIndigo),
                      const SizedBox(width: 4),
                      Text(
                        'Tap markers for details',
                        style: TextStyle(
                          color: primaryIndigo,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Map
                Expanded(
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter:
                              LatLng(7.8731, 80.7718), // Center of Sri Lanka
                          initialZoom: 7.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c'],
                          ),
                          MarkerLayer(
                            markers: filteredDestinations.map((destination) {
                              return Marker(
                                width: 120.0,
                                height: 70.0,
                                point: LatLng(
                                  destination['latitude'],
                                  destination['longitude'],
                                ),
                                child: GestureDetector(
                                  onTap: () => _showDestinationPopup(
                                      context, destination),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              primaryIndigo.withOpacity(0.85),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          destination['title'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                        size: 30.0,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),

                      // Zoom control buttons
                      Positioned(
                        right: 16,
                        bottom: 100,
                        child: Column(
                          children: [
                            FloatingActionButton.small(
                              heroTag: 'zoomIn',
                              onPressed: () {
                                _mapController.move(
                                  _mapController.camera.center,
                                  _mapController.camera.zoom + 1,
                                );
                              },
                              backgroundColor: Colors.white,
                              foregroundColor: primaryIndigo,
                              child: const Icon(Icons.add),
                            ),
                            const SizedBox(height: 8),
                            FloatingActionButton.small(
                              heroTag: 'zoomOut',
                              onPressed: () {
                                _mapController.move(
                                  _mapController.camera.center,
                                  _mapController.camera.zoom - 1,
                                );
                              },
                              backgroundColor: Colors.white,
                              foregroundColor: primaryIndigo,
                              child: const Icon(Icons.remove),
                            ),
                          ],
                        ),
                      ),

                      // Center on Sri Lanka button
                      Positioned(
                        left: 16,
                        bottom: 100,
                        child: FloatingActionButton.small(
                          heroTag: 'centerSriLanka',
                          onPressed: () {
                            _mapController.move(
                              LatLng(7.8731, 80.7718),
                              7.0,
                            );
                          },
                          backgroundColor: Colors.white,
                          foregroundColor: primaryIndigo,
                          child: const Icon(Icons.my_location),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _showDestinationPopup(
      BuildContext context, Map<String, dynamic> destination) {
    final Color primaryIndigo = Colors.indigo;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle for the bottom sheet
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Destination info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Destination image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: destination['imageUrl'] != null
                        ? Image.network(
                            destination['imageUrl'],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),

                  // Destination details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          destination['title'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryIndigo,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: primaryIndigo.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                destination['category'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: primaryIndigo,
                                ),
                              ),
                            ),
                            if (destination['rating'] > 0) ...[
                              const SizedBox(width: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${destination['rating'].toStringAsFixed(1)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          destination['location'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Description preview
            if (destination['description'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  destination['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.directions),
                      label: const Text('Directions'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryIndigo,
                        side: BorderSide(color: primaryIndigo),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _openInGoogleMaps(
                        destination['latitude'],
                        destination['longitude'],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.info_outline),
                      label: const Text('View Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryIndigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _viewDestinationDetails(destination['id']);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
