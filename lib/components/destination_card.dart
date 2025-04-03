import 'package:flutter/material.dart';
import '../models/destination.dart';

class DestinationCard extends StatelessWidget {
  final Destination destination;
  final double cardWidth;
  final double maxHeight;
  final double imageHeight;

  const DestinationCard({
    super.key, 
    required this.destination,
    this.cardWidth = 370,
    this.maxHeight = 1000,
    this.imageHeight = 160,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cardWidth,
      child: Card(
        elevation: 2,
        color: const Color.fromARGB(255, 193, 193, 230), 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Section (fixed height)
            SizedBox(
              height: imageHeight,
              width: double.infinity,
              child: Stack(
                children: [
                  // Main image
                  destination.images.isNotEmpty
                      ? Image.network(
                          destination.images.first,
                          width: double.infinity,
                          height: imageHeight,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                              _buildPlaceholderImage(),
                        )
                      : _buildPlaceholderImage(),
                  
                  // Rating overlay
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, 
                              size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            destination.averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Category badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(destination.category),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        destination.category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title and Reviews
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          destination.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.reviews, 
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            _formatReviewCount(destination.reviews),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on, 
                          size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          destination.location,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Features (first 2 features)
                  if (destination.features.isNotEmpty)
                    SizedBox(
                      height: 24,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: destination.features
                            .take(2)
                            .map((feature) => Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Chip(
                                    label: Text(
                                      feature,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    backgroundColor: Colors.grey[100],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  
                  const SizedBox(height: 12),
                  
                  // Description with proper constraints
             // Flexible description section
// Flexible description section with 5-line limit
Flexible(
  child: SingleChildScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    child: Text(
      destination.description,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
      ),
      maxLines: 5,  // Limits to 5 lines
      overflow: TextOverflow.ellipsis,  // Shows ellipsis if truncated
    ),
  ),
),
                  const SizedBox(height: 12),
                  
                  // Explore button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: _getCategoryColor(destination.category),
                      ),
                      child: const Text(
                        'Explore',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: imageHeight,
      color: _getRandomColor(),
      child: Center(
        child: Icon(
          Icons.photo,
          size: 40,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  Color _getRandomColor() {
    final colors = [
      Colors.blue.shade400,
      Colors.red.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
    ];
    return colors[(destination.title.length % colors.length)];
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'city':
        return Colors.blue.shade600;
      case 'beach':
        return Colors.teal.shade600;
      case 'cultural':
        return Colors.purple.shade600;
      case 'mountain':
        return Colors.brown.shade600;
      case 'historical':
        return Colors.orange.shade600;
      case 'nature':
        return Colors.green.shade600;
      default:
        return const Color.fromARGB(255, 38, 98, 126);
    }
  }

  String _formatReviewCount(int reviews) {
    if (reviews >= 1000) {
      return '${(reviews / 1000).toStringAsFixed(1)}k';
    }
    return reviews.toString();
  }
}