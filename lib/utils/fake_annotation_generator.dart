
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import '../models/annotation.dart';


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
