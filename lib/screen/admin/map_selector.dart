import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapSelectorScreen extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;

  const MapSelectorScreen({
    Key? key,
    required this.initialLatitude,
    required this.initialLongitude,
  }) : super(key: key);

  @override
  State<MapSelectorScreen> createState() => _MapSelectorScreenState();
}

class _MapSelectorScreenState extends State<MapSelectorScreen> {
  late double _latitude;
  late double _longitude;
  final MapController _mapController = MapController();
  String _address = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _latitude = widget.initialLatitude;
    _longitude = widget.initialLongitude;

    // Get address for initial coords if they were provided
    if (_latitude != 0.0 && _longitude != 0.0) {
      _getAddressFromCoordinates(_latitude, _longitude);
    }
  }

  Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Using OpenStreetMap's Nominatim service to get address from coordinates
      final response = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1'),
        headers: {'User-Agent': 'TourMate App'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _address = data['display_name'] ?? '';
        });
      } else {
        setState(() {
          _address =
              'Lat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}';
        });
      }
    } catch (e) {
      setState(() {
        _address =
            'Lat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, {
                'latitude': _latitude,
                'longitude': _longitude,
                'address': _address,
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(_latitude, _longitude),
              initialZoom: 13.0,
              onTap: (tapPosition, LatLng point) {
                setState(() {
                  _latitude = point.latitude;
                  _longitude = point.longitude;
                });
                _getAddressFromCoordinates(_latitude, _longitude);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: LatLng(_latitude, _longitude),
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
          // Information panel at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white.withOpacity(0.9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tap on the map to select a location',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Text(_address.isEmpty
                          ? 'No location selected'
                          : 'Address: $_address'),
                  const SizedBox(height: 8),
                  Text(
                      'Coordinates: Lat: ${_latitude.toStringAsFixed(6)}, Lng: ${_longitude.toStringAsFixed(6)}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'latitude': _latitude,
                        'longitude': _longitude,
                        'address': _address,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Confirm Location'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
