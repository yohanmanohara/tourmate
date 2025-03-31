import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong2/latlong.dart';

class DirectionsService {
  static final Dio _dio = Dio();

  static Future<Map<String, dynamic>?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final String accessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';

    if (accessToken.isEmpty) {
      throw Exception('Mapbox access token not found');
    }

    try {
      final response = await _dio.get(
        'https://api.mapbox.com/directions/v5/mapbox/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}',
        queryParameters: {
          'access_token': accessToken,
          'overview': 'full',
          'geometries': 'geojson',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry'];

          // Distance in meters
          final distance = route['distance'] / 1000; // Convert to kilometers

          // Duration in seconds
          final duration = route['duration'] / 60; // Convert to minutes

          // Decode polyline
          List<LatLng> points = [];
          final coordinates = geometry['coordinates'] as List;

          for (var coordinate in coordinates) {
            // Mapbox returns [longitude, latitude]
            points.add(LatLng(coordinate[1], coordinate[0]));
          }

          return {
            'distance': distance,
            'duration': duration,
            'polyline': points,
          };
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get directions: $e');
    }
  }
}
