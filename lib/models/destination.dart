import 'package:cloud_firestore/cloud_firestore.dart';

class Destination {
  final String? id;
  final String title;
  final String description;
  final String category;
  final String location;
  final List<String> features;
  final List<String> images;
  final double averageRating;
  final int reviews;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, double> coordinates;

  Destination({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.features,
    required this.images,
    this.averageRating = 0.0,
    this.reviews = 0,
    required this.createdAt,
    required this.updatedAt,
    required this.coordinates,
  });

  factory Destination.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Handle Timestamp to DateTime conversion
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    
    // Handle list fields with null safety
    final features = List<String>.from(data['features'] ?? []);
    final images = List<String>.from(data['images'] ?? []);
    
    // Handle coordinates map with null safety
    final coordinatesData = data['coordinates'] as Map<String, dynamic>? ?? {};
    final coordinates = {
      'latitude': (coordinatesData['latitude'] as num?)?.toDouble() ?? 0.0,
      'longitude': (coordinatesData['longitude'] as num?)?.toDouble() ?? 0.0,
    };

    return Destination(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? 'Other',
      location: data['location'] as String? ?? '',
      features: features,
      images: images,
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviews: (data['reviews'] as int?) ?? 0,
      createdAt: createdAt,
      updatedAt: updatedAt,
      coordinates: coordinates,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'features': features,
      'images': images,
      'averageRating': averageRating,
      'reviews': reviews,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'coordinates': coordinates,
      if (id != null) 'id': id,
    };
  }

  // Optional: Create a copyWith method for updates
  Destination copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? location,
    List<String>? features,
    List<String>? images,
    double? averageRating,
    int? reviews,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, double>? coordinates,
  }) {
    return Destination(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      features: features ?? this.features,
      images: images ?? this.images,
      averageRating: averageRating ?? this.averageRating,
      reviews: reviews ?? this.reviews,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      coordinates: coordinates ?? this.coordinates,
    );
  }
}