import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
   HomePage({super.key});

  // Enhanced dummy data with more details
  final List<Map<String, dynamic>> _travelDestinations = [
    {
      'name': 'San Francisco',
      'image': 'sf.jpg',
      'currentTemp': '18°C',
      'highTemp': '22°C',
      'lowTemp': '14°C',
      'price': '\$120/night',
      'rating': 4.7,
      'reviews': 1243,
      'description': 'Golden Gate City with iconic bridges',
      'activities': ['Alcatraz', 'Golden Gate', 'Cable Cars'],
      'deal': '20% off this week',
      'dealColor': Colors.red,
    },
    {
      'name': 'Paris',
      'image': 'paris.jpg',
      'currentTemp': '12°C',
      'highTemp': '16°C',
      'lowTemp': '8°C',
      'price': '\$250/night',
      'rating': 4.9,
      'reviews': 2856,
      'description': 'City of Love and Lights',
      'activities': ['Eiffel Tower', 'Louvre', 'Seine Cruise'],
      'deal': 'Free cancellation',
      'dealColor': Colors.green,
    },
    {
      'name': 'Tokyo',
      'image': 'tokyo.jpg',
      'currentTemp': '22°C',
      'highTemp': '25°C',
      'lowTemp': '18°C',
      'price': '\$320/night',
      'rating': 4.8,
      'reviews': 1987,
      'description': 'Vibrant metropolis blending tradition and tech',
      'activities': ['Shibuya Crossing', 'Tsukiji Market', 'Senso-ji'],
      'deal': 'Early bird discount',
      'dealColor': Colors.orange,
    },
    {
      'name': 'Sydney',
      'image': 'sydney.jpg',
      'currentTemp': '25°C',
      'highTemp': '28°C',
      'lowTemp': '21°C',
      'price': '\$280/night',
      'rating': 4.6,
      'reviews': 1672,
      'description': 'Harbor city with iconic opera house',
      'activities': ['Opera House', 'Bondi Beach', 'Harbour Bridge'],
      'deal': 'Last minute deal',
      'dealColor': Colors.purple,
    },
    {
      'name': 'New York',
      'image': 'ny.jpg',
      'currentTemp': '15°C',
      'highTemp': '18°C',
      'lowTemp': '12°C',
      'price': '\$200/night',
      'rating': 4.5,
      'reviews': 3124,
      'description': 'The city that never sleeps',
      'activities': ['Times Square', 'Central Park', 'Statue of Liberty'],
      'deal': 'Weekend special',
      'dealColor': Colors.blue,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Good Morning',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 16, color: Colors.blue[700]),
                              const SizedBox(width: 6),
                              Text(
                                DateFormat('EEEE, MMMM d').format(DateTime.now()),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Having a nice day',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),

                // Weather card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue[600]!, Colors.blue[400]!],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'New York',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Partly Cloudy',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.wb_cloudy,
                            size: 32,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '22°',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildCompactMetric(Icons.water_drop, '65%', 'Humidity'),
                              const SizedBox(height: 8),
                              _buildCompactMetric(Icons.air, '12 km/h', 'Wind'),
                              const SizedBox(height: 8),
                              _buildCompactMetric(Icons.speed, '1013 hPa', 'Pressure'),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildCompactTempRange('18°', 'Min'),
                          _buildCompactTempRange('26°', 'Max'),
                        ],
                      ),
                    ],
                  ),
                ),
            
                // Travel suggestions section (now shows by default)
                const SizedBox(height: 24),
                const Text(
                  'Recommended Destinations',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Popular destinations you might like',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                
                SizedBox(
                  height: 280,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _travelDestinations.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final destination = _travelDestinations[index];
                      return TravelDestinationCard(destination: destination);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
          
      
      
    );
  }

  Widget _buildCompactMetric(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 4),
        Text(
          '$value ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactTempRange(String temp, String label) {
    return Column(
      children: [
        Text(
          temp,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

class TravelDestinationCard extends StatelessWidget {
  final Map<String, dynamic> destination;

  const TravelDestinationCard({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Destination image with temperature overlay
          Stack(
            children: [
              // Image placeholder (replace with actual Image.asset)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  height: 140,
                  color: _getRandomColor(),
                  child: Center(
                    child: Icon(
                      Icons.photo,
                      size: 50,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
              // Temperature overlay
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.thermostat, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        destination['currentTemp'],
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
              // Deal badge
              if (destination['deal'] != null)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: destination['dealColor'] ?? Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      destination['deal'],
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
          
          // Destination details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Destination name and rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      destination['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, size: 18, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          destination['rating'].toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Temperature range
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'H: ${destination['highTemp']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'L: ${destination['lowTemp']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Short description
                Text(
                  destination['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                // Price and book button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      destination['price'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Book',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  // Helper function to generate random colors for placeholders
  Color _getRandomColor() {
    final colors = [
      Colors.blue.shade400,
      Colors.red.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
    ];
    return colors[(destination['name'].length % colors.length)];
  }
}