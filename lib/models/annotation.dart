
import 'package:ar_location_view/ar_location_view.dart';
import 'package:geolocator/geolocator.dart';
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