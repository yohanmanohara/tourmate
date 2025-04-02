class WeatherData {
  final String city;
  final double temperature;
  final double tempMin;
  final double tempMax;
  final double windSpeed;
  final int humidity;
  final int pressure;
  final String condition;

  WeatherData({
    required this.city,
    required this.temperature,
    required this.tempMin,
    required this.tempMax,
    required this.windSpeed,
    required this.humidity,
    required this.pressure,
    required this.condition,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    // Get current weather data
    final current = json['current_weather'];
    final hourly = json['hourly'];
    final daily = json['daily'];

    // Get the first hourly data point (current hour)
    final hourlyIndex = 0;
    
    // Convert weather code to human-readable condition
    final weatherCode = current['weathercode'];
    final condition = _getWeatherCondition(weatherCode);

    return WeatherData(
      city: json['city'] ?? 'Unknown',
      temperature: current['temperature'].toDouble(),
      tempMin: daily['temperature_2m_min'][0].toDouble(),
      tempMax: daily['temperature_2m_max'][0].toDouble(),
      windSpeed: current['windspeed'].toDouble(),
      humidity: hourly['relativehumidity_2m'][hourlyIndex].toInt(),
      pressure: 1015, // Open-Meteo doesn't provide pressure in free tier
      condition: condition,
    );
  }

  static String _getWeatherCondition(int code) {
    // Simplified weather code interpretation
    if (code == 0) return 'Clear';
    if (code <= 3) return 'Partly cloudy';
    if (code <= 48) return 'Fog';
    if (code <= 67) return 'Rain';
    if (code <= 77) return 'Snow';
    if (code <= 99) return 'Thunderstorm';
    return 'Unknown';
  }
}