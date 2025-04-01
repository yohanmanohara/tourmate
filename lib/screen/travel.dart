import 'package:flutter/material.dart';

class TravelPage extends StatelessWidget {
  const TravelPage({super.key});

  // Dummy data list
  final List<Map<String, dynamic>> destinations = const [
    {
      'image': 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34',
      'title': 'Paris, France',
      'description': 'The city of love and lights with iconic landmarks like the Eiffel Tower and Louvre Museum.',
      'rating': 4.8,
      'price': 1200,
    },
    {
      'image': 'https://images.unsplash.com/photo-1538970272646-f61fabb3a8a3',
      'title': 'Kyoto, Japan',
      'description': 'Ancient temples, traditional tea houses, and beautiful cherry blossoms in spring.',
      'rating': 4.9,
      'price': 1800,
    },
    {
      'image': 'https://images.unsplash.com/photo-1518391846015-55a9cc003b25',
      'title': 'Santorini, Greece',
      'description': 'Whitewashed buildings with blue domes overlooking the Aegean Sea.',
      'rating': 4.7,
      'price': 1500,
    },
    {
      'image': 'https://images.unsplash.com/photo-1523482580672-f109ba8cb9be',
      'title': 'New York, USA',
      'description': 'The city that never sleeps with iconic skyscrapers and Broadway shows.',
      'rating': 4.6,
      'price': 1100,
    },
    {
      'image': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4',
      'title': 'Bali, Indonesia',
      'description': 'Tropical paradise with lush jungles, stunning beaches, and vibrant culture.',
      'rating': 4.8,
      'price': 900,
    },
    {
      'image': 'https://images.unsplash.com/photo-1527631746610-bca00a040d60',
      'title': 'Rome, Italy',
      'description': 'The Eternal City with ancient ruins, Renaissance art, and delicious cuisine.',
      'rating': 4.7,
      'price': 1300,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...destinations.map((destination) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildDestinationCard(
                image: destination['image'],
                title: destination['title'],
                description: destination['description'],
                rating: destination['rating'],
                price: destination['price'],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationCard({
    required String image,
    required String title,
    required String description,
    required double rating,
    required int price,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              image,
              height: 180,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, size: 50),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Chip(
                      backgroundColor: Colors.amber.withOpacity(0.2),
                      label: Text(
                        '\$$price',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    Text(
                      ' $rating',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                      child: const Text('Explore'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}