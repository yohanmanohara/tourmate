import 'dart:ui';

class Destination {
  final String name;
  final String image;
  final String currentTemp;
  final String highTemp;
  final String lowTemp;
  final String price;
  final double rating;
  final int reviews;
  final String description;
  final List<String> activities;
  final String? deal;
  final Color? dealColor;

  Destination({
    required this.name,
    required this.image,
    required this.currentTemp,
    required this.highTemp,
    required this.lowTemp,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.description,
    required this.activities,
    this.deal,
    this.dealColor,
  });
}