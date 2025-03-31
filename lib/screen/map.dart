import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math';
import '../services/directions_service.dart'; // Add this import

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

  // Current location properties
  final Location _locationService = Location();
  LocationData? _currentLocation;
  bool _isGettingLocation = false;

  // Directions properties
  final Dio _dio = Dio();
  List<LatLng> _polylineCoordinates = [];
  bool _isCalculatingRoute = false;
  Map<String, dynamic>? _selectedDestination;
  double _routeDistance = 0;
  double _routeDuration = 0;

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
    _initializeLocationService();
  }

  Future<void> _initializeLocationService() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location service is enabled
    serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Check if location permission is granted
    permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Get current location
    _getCurrentLocation();

    // Subscribe to location changes
    _locationService.onLocationChanged.listen((LocationData locationData) {
      if (mounted) {
        setState(() {
          _currentLocation = locationData;

          // If route is active, update route
          if (_selectedDestination != null && _polylineCoordinates.isNotEmpty) {
            _getDirections();
          }
        });
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      final locationData = await _locationService.getLocation();
      if (mounted) {
        setState(() {
          _currentLocation = locationData;
          _isGettingLocation = false;

          // Center map on current location
          if (_currentLocation != null) {
            _mapController.move(
              LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
              14.0,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    }
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
    Navigator.pushNamed(context, '/user-destination-details', arguments: id);
  }

  Future<void> _getDirections() async {
    if (_currentLocation == null || _selectedDestination == null) {
      return;
    }

    setState(() {
      _isCalculatingRoute = true;
      _polylineCoordinates = [];
    });

    try {
      final origin = LatLng(
        _currentLocation!.latitude!,
        _currentLocation!.longitude!,
      );

      final destination = LatLng(
        _selectedDestination!['latitude'],
        _selectedDestination!['longitude'],
      );

      final directions = await DirectionsService.getDirections(
        origin: origin,
        destination: destination,
      );

      if (directions != null) {
        setState(() {
          _polylineCoordinates = directions['polyline'];
          _routeDistance = directions['distance'];
          _routeDuration = directions['duration'];
          _isCalculatingRoute = false;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not find a route')),
          );
          setState(() {
            _isCalculatingRoute = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error calculating route: $e')),
        );
        setState(() {
          _isCalculatingRoute = false;
        });
      }
    }
  }

  void _clearRoute() {
    setState(() {
      _polylineCoordinates = [];
      _selectedDestination = null;
      _routeDistance = 0;
      _routeDuration = 0;
    });
  }

  String _formatDuration(double minutes) {
    if (minutes < 60) {
      return '${minutes.round()} min';
    } else {
      final hours = (minutes / 60).floor();
      final remainingMinutes = (minutes % 60).round();
      return '$hours h ${remainingMinutes > 0 ? '$remainingMinutes min' : ''}';
    }
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
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.white),
            tooltip: 'My location',
            onPressed: _getCurrentLocation,
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

                          // Route polyline
                          if (_polylineCoordinates.isNotEmpty)
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: _polylineCoordinates,
                                  color: Colors.blue,
                                  strokeWidth: 4.0,
                                ),
                              ],
                            ),

                          // Current location marker
                          if (_currentLocation != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  width: 30.0,
                                  height: 30.0,
                                  point: LatLng(
                                    _currentLocation!.latitude!,
                                    _currentLocation!.longitude!,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.7),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.my_location,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          // Destination markers
                          MarkerLayer(
                            markers: filteredDestinations.map((destination) {
                              final isSelected = _selectedDestination != null &&
                                  _selectedDestination!['id'] ==
                                      destination['id'];

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
                                          color: isSelected
                                              ? Colors.blue.withOpacity(0.85)
                                              : primaryIndigo.withOpacity(0.85),
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
                                      Icon(
                                        Icons.location_on,
                                        color: isSelected
                                            ? Colors.blue
                                            : Colors.red,
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

                      // Location and center buttons
                      Positioned(
                        left: 16,
                        bottom: 100,
                        child: Column(
                          children: [
                            FloatingActionButton.small(
                              heroTag: 'myLocation',
                              onPressed: () {
                                if (_currentLocation != null) {
                                  _mapController.move(
                                    LatLng(
                                      _currentLocation!.latitude!,
                                      _currentLocation!.longitude!,
                                    ),
                                    14.0,
                                  );
                                } else {
                                  _getCurrentLocation();
                                }
                              },
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue,
                              child: const Icon(Icons.my_location),
                            ),
                            const SizedBox(height: 8),
                            FloatingActionButton.small(
                              heroTag: 'centerSriLanka',
                              onPressed: () {
                                _mapController.move(
                                  LatLng(7.8731, 80.7718),
                                  7.0,
                                );
                              },
                              backgroundColor: Colors.white,
                              foregroundColor: primaryIndigo,
                              child: const Icon(Icons.public),
                            ),
                          ],
                        ),
                      ),

                      // Route information card
                      if (_polylineCoordinates.isNotEmpty &&
                          _selectedDestination != null)
                        Positioned(
                          top: 8,
                          left: 8,
                          right: 8,
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.directions,
                                          color: Colors.blue),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Directions to ${_selectedDestination!['title']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: _clearRoute,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          const Text(
                                            'Distance',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            '${_routeDistance.toStringAsFixed(1)} km',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const Text(
                                            'Duration',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            _formatDuration(_routeDuration),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // Loading indicators
                      if (_isGettingLocation || _isCalculatingRoute)
                        Positioned(
                          top: 70,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _isCalculatingRoute
                                          ? Colors.blue
                                          : primaryIndigo,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isCalculatingRoute
                                      ? 'Calculating route...'
                                      : 'Getting location...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _isCalculatingRoute
                                        ? Colors.blue
                                        : primaryIndigo,
                                  ),
                                ),
                              ],
                            ),
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

            // Distance from current location
            if (_currentLocation != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.straighten, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Distance: ${_calculateHaversineDistance(
                        _currentLocation!.latitude!,
                        _currentLocation!.longitude!,
                        destination['latitude'],
                        destination['longitude'],
                      ).toStringAsFixed(1)} km (as the crow flies)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
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
                      label: const Text('Google Maps'),
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
                      icon: const Icon(Icons.navigation),
                      label: const Text('Get Directions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        if (_currentLocation == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Getting your location...')),
                          );
                          _getCurrentLocation();
                          return;
                        }

                        setState(() {
                          _selectedDestination = destination;
                        });

                        _getDirections();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.info_outline),
                label: const Text('View Details'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryIndigo,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
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
    );
  }

  // Calculate straight-line distance using Haversine formula
  double _calculateHaversineDistance(
      double startLat, double startLng, double endLat, double endLng) {
    const double earthRadius = 6371; // in kilometers

    final dLat = _toRadians(endLat - startLat);
    final dLng = _toRadians(endLng - startLng);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(startLat)) *
            cos(_toRadians(endLat)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }
}
