import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ARMapScreen extends StatelessWidget {
  ARMapScreen({Key? key}) : super(key: key);
  final List<LatLng> arLocations = [
    LatLng(6.9271, 79.8612), // Colombo
    LatLng(7.2906, 80.6337), // Kandy
    // Add more locations as needed
  ];

  void _openInGoogleMaps(LatLng location) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${location.latitude},${location.longitude}';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not open Google Maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(7.8731, 80.7718), // Center of Sri Lanka
        initialZoom: 7.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: arLocations.map((location) {
            return Marker(
              width: 80.0,
              height: 80.0,
              point: location,
              child: GestureDetector(
                onTap: () => _openInGoogleMaps(location),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40.0,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
