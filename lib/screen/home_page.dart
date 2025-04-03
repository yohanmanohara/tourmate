import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/weather_card.dart';
import '../components/destination_card.dart';
import '../models/destination.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CollectionReference destinationsCollection =
      FirebaseFirestore.instance.collection('destinations');
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  List<String> _userPreferences = [];
  late Future<void> _preferencesFuture;
  late Future<List<Destination>> _recommendedDestinationsFuture;
  late Future<List<Destination>> _popularDestinationsFuture;

  @override
  void initState() {
    super.initState();
    _preferencesFuture = _fetchUserPreferences().then((_) {
      _loadData();
    });
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  Future<void> _fetchUserPreferences() async {
    try {
      // Replace 'current_user_id' with your actual user ID retrieval logic
      final userDoc = await usersCollection.doc('current_user_id').get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _userPreferences = List<String>.from(data['preferences'] ?? []);
        });
      }
    } catch (e) {
      debugPrint('Error fetching user preferences: $e');
    }
  }

  void _loadData() {
    _recommendedDestinationsFuture = _fetchRecommendedDestinations();
    _popularDestinationsFuture = _fetchPopularDestinations();
  }

  Future<List<Destination>> _fetchRecommendedDestinations() async {
    try {
      Query query = destinationsCollection;
      
      if (_userPreferences.isNotEmpty) {
        query = query.where('category', whereIn: _userPreferences);
      }

      final querySnapshot = await query
          .orderBy('averageRating', descending: true)
          .limit(5)
          .get();

      return querySnapshot.docs
          .map((doc) => Destination.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching recommended destinations: $e');
      return [];
    }
  }

  Future<List<Destination>> _fetchPopularDestinations() async {
    try {
      final querySnapshot = await destinationsCollection
          .orderBy('reviews', descending: true)
          .limit(5)
          .get();

      return querySnapshot.docs
          .map((doc) => Destination.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching popular destinations: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _preferencesFuture,
          builder: (context, preferencesSnapshot) {
            if (preferencesSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (preferencesSnapshot.hasError) {
              return Center(child: Text('Error loading preferences: ${preferencesSnapshot.error}'));
            }
            
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _loadData();
                });
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                              Text(
                                _getTimeBasedGreeting(),
                                style: const TextStyle(
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
                        'Having a nice day 🌟',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Weather card
                      WeatherCard(),
                      
                      // Recommended destinations section
                      const SizedBox(height: 24),
                      const Text(
                        'Recommended For You',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _userPreferences.isNotEmpty
                            ? 'Based on your preferences: ${_userPreferences.join(', ')}'
                            : 'Popular destinations you might like',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      FutureBuilder<List<Destination>>(
                        future: _recommendedDestinationsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          
                          final destinations = snapshot.data ?? [];
                          
                          if (destinations.isEmpty) {
                            return const Text('No recommended destinations found');
                          }
                          
                          return SizedBox(
                            height: 430,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: destinations.length,
                              separatorBuilder: (context, index) => const SizedBox(width: 16),
                              itemBuilder: (context, index) {
                                return DestinationCard(destination: destinations[index]);
                              },
                            ),
                          );
                        },
                      ),

                      // Popular destinations section
                      const SizedBox(height: 24),
                      const Text(
                        'Popular Destinations',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Trending destinations travelers love',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      FutureBuilder<List<Destination>>(
                        future: _popularDestinationsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          
                          final destinations = snapshot.data ?? [];
                          
                          if (destinations.isEmpty) {
                            return const Text('No popular destinations found');
                          }
                          
                          return SizedBox(
                            height: 430,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: destinations.length,
                              separatorBuilder: (context, index) => const SizedBox(width: 16),
                              itemBuilder: (context, index) {
                                return DestinationCard(destination: destinations[index]);
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
