import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  Future<WeatherData> fetchWeatherData() async {
    // Replace with actual API call
    final response = await http.get(Uri.parse('https://api.weatherapi.com/v1/current.json?key=YOUR_KEY&q=London'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return WeatherData(
        temperature: data['current']['temp_c'],
        humidity: data['current']['humidity'],
        windSpeed: data['current']['wind_kph'],
        windDirection: data['current']['wind_degree'],
      );
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}