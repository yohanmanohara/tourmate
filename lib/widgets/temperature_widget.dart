import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const WeatherDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WeatherDashboard extends StatelessWidget {
  const WeatherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
     
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          children: const [
            TemperatureWidget(temperature: 23.5),
            HumidityWidget(humidity: 65),
            WindWidget(speed: 12.3, direction: 45),
            // Add more weather components as needed
          ],
        ),
      ),
    );
  }
}

class WeatherCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final String iconPath;
  final Color gradientStart;
  final Color gradientEnd;
  final Widget? child;

  const WeatherCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.iconPath,
    this.gradientStart = const Color(0xFF00C6FB),
    this.gradientEnd = const Color(0xFF005BEA),
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                iconPath,
                width: 24,
                height: 24,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class TemperatureWidget extends StatelessWidget {
  final double temperature;
  final String unit;

  const TemperatureWidget({
    super.key,
    required this.temperature,
    this.unit = '°C',
  });

  @override
  Widget build(BuildContext context) {
    return WeatherCard(
      title: 'Temperature',
      value: temperature.toStringAsFixed(1),
      unit: unit,
      iconPath: 'assets/icons/temperature.svg',
      gradientStart: const Color(0xFFFF7E5F),
      gradientEnd: const Color(0xFFFEB47B),
    );
  }
}

class HumidityWidget extends StatelessWidget {
  final int humidity;
  
  const HumidityWidget({
    super.key,
    required this.humidity,
  });

  @override
  Widget build(BuildContext context) {
    return WeatherCard(
      title: 'Humidity',
      value: humidity.toString(),
      unit: '%',
      iconPath: 'assets/icons/humidity.svg',
      gradientStart: const Color(0xFF4AC29A),
      gradientEnd: const Color(0xFFBDFFF3),
      child: Column(
        children: [
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: humidity / 100,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }
}

class WindWidget extends StatelessWidget {
  final double speed;
  final int direction;
  final String unit;

  const WindWidget({
    super.key,
    required this.speed,
    required this.direction,
    this.unit = 'km/h',
  });

  @override
  Widget build(BuildContext context) {
    return WeatherCard(
      title: 'Wind',
      value: speed.toStringAsFixed(1),
      unit: unit,
      iconPath: 'assets/icons/wind.svg',
      gradientStart: const Color(0xFFA1C4FD),
      gradientEnd: const Color(0xFFC2E9FB),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Transform.rotate(
            angle: direction * (3.1415926535 / 180),
            child: const Icon(
              Icons.navigation,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}