import 'package:flutter/material.dart';
import 'package:ar_location_view/ar_location_view.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Annotation> annotations = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ArLocationWidget(
          annotations: annotations,
          showDebugInfoSensor: false,
          annotationWidth: 180,
          annotationHeight: 60,
          radarPosition: RadarPosition.bottomCenter,
          annotationViewBuilder: (context, annotation) {
            return AnnotationView(
              key: ValueKey(annotation.uid),
              annotation: annotation as Annotation,
            );
          },
          radarWidth: 160,
          scaleWithDistance: false,
          onLocationChange: (Position position) {
            Future.delayed(const Duration(seconds: 5), () {
              setState(() {
                annotations = fakeAnnotation(position: position, numberMaxPoi: 10);
              });
            });
          },
        ),
      ),
    );
  }
}

// Enum for Annotation Types
enum AnnotationType { pharmacy, hotel, library }

// Custom Annotation Model
class Annotation extends ArAnnotation {
  final AnnotationType type;

  Annotation({
    required super.uid,
    required super.position, // Keep Position as required
    required this.type,
  });
}

// Annotation View Widget
class AnnotationView extends StatelessWidget {
  const AnnotationView({Key? key, required this.annotation}) : super(key: key);

  final Annotation annotation;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                ),
              ),
              child: typeFactory(annotation.type),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    annotation.type.toString().split('.').last, // Get enum name
                    maxLines: 1,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${annotation.distanceFromUser.toInt()} m'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget typeFactory(AnnotationType type) {
    IconData iconData = Icons.place;
    Color color = Colors.grey;

    switch (type) {
      case AnnotationType.pharmacy:
        iconData = Icons.local_pharmacy_outlined;
        color = Colors.red;
        break;
      case AnnotationType.hotel:
        iconData = Icons.hotel_outlined;
        color = Colors.green;
        break;
      case AnnotationType.library:
        iconData = Icons.library_books_outlined;
        color = Colors.blue;
        break;
    }

    return Icon(iconData, size: 40, color: color);
  }
}

// Function to Generate Fake Annotations (POIs)
List<Annotation> fakeAnnotation({required Position position, int numberMaxPoi = 10}) {
  List<Annotation> annotations = [];
  Random random = Random();

  for (int i = 0; i < numberMaxPoi; i++) {
    double randomLat = position.latitude + (random.nextDouble() - 0.5) / 500;
    double randomLon = position.longitude + (random.nextDouble() - 0.5) / 500;

    AnnotationType type = AnnotationType.values[random.nextInt(AnnotationType.values.length)];

    annotations.add(
      Annotation(
        uid: i.toString(),
        position: Position(
          latitude: randomLat,
          longitude: randomLon,
          accuracy: 1.0,
          altitude: 0.0,
          altitudeAccuracy: 1.0,
          heading: 0.0,
          headingAccuracy: 1.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          timestamp: DateTime.now(),
        ), // ✅ Fixed: Using Position instead of LatLng
        type: type,
      ),
    );
  }

  return annotations;
}
