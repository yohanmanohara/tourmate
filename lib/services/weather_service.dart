import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // Open-Meteo API endpoints
  static const String _weatherUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String _geocodingUrl = 'https://geocoding-api.open-meteo.com/v1/search';
  static const String _reverseGeocodingUrl = 'https://geocoding-api.open-meteo.com/v1/reverse';

  Future<Map<String, dynamic>> getWeather(String city) async {
    try {
      // First get coordinates for the city
      final geoResponse = await http.get(
        Uri.parse('$_geocodingUrl?name=$city&count=1'),
      );

      if (geoResponse.statusCode != 200) {
        throw Exception('Failed to find city: ${geoResponse.statusCode}');
      }

      final geoData = json.decode(geoResponse.body);
      if (geoData['results'] == null || geoData['results'].isEmpty) {
        throw Exception('City not found');
      }

      final result = geoData['results'][0];
      final lat = result['latitude'];
      final lon = result['longitude'];
      final cityName = result['name'];

      // Then get weather for those coordinates
      return await _fetchWeatherData(lat, lon, cityName);
    } catch (e) {
      throw Exception('Failed to connect to weather service: $e');
    }
  }

  Future<Map<String, dynamic>> getWeatherByCoordinates(double latitude, double longitude) async {
    try {
      // First get city name from coordinates
      final geoResponse = await http.get(
        Uri.parse('$_reverseGeocodingUrl?latitude=$latitude&longitude=$longitude'),
      );

      String cityName = 'Current Location';
      if (geoResponse.statusCode == 200) {
        final geoData = json.decode(geoResponse.body);
        if (geoData['results'] != null && geoData['results'].isNotEmpty) {
          cityName = geoData['results'][0]['name'] ?? cityName;
        }
      }

      // Then get weather data
      return await _fetchWeatherData(latitude, longitude, cityName);
    } catch (e) {
      throw Exception('Failed to get weather by coordinates: $e');
    }
  }

  Future<Map<String, dynamic>> _fetchWeatherData(double lat, double lon, String cityName) async {
    final weatherResponse = await http.get(
      Uri.parse('$_weatherUrl?latitude=$lat&longitude=$lon&current_weather=true&hourly=temperature_2m,relativehumidity_2m,windspeed_10m&daily=weathercode,temperature_2m_max,temperature_2m_min'),
    );

    if (weatherResponse.statusCode == 200) {
      final weatherData = json.decode(weatherResponse.body);
      // Add city name to the response since Open-Meteo doesn't provide it
      weatherData['city'] = cityName;
      return weatherData;
    } else {
      throw Exception('Failed to load weather data: ${weatherResponse.statusCode}');
    }
  }
}