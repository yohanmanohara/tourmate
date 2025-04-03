import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../widgets/admin_bottom_menu.dart';

class ManageReviewsScreen extends StatefulWidget {
  const ManageReviewsScreen({Key? key}) : super(key: key);

  @override
  State<ManageReviewsScreen> createState() => _ManageReviewsScreenState();
}

class _ManageReviewsScreenState extends State<ManageReviewsScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All Reviews';
  int _selectedIndex = 3; // Set to 3 for Reviews tab
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  final List<String> _filterOptions = [
    'All Reviews',
    'Recent First',
    'Oldest First',
    'Highest Rating',
    'Lowest Rating',
  ];

  // Add these class variables for caching destination data
  final Map<String, String> _destinationNameCache = {};
  bool _loadingDestinations = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Delete review from Firestore
  Future<void> _deleteReview(String reviewId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the review details before deleting to update destination stats
      final reviewDoc = await FirebaseFirestore.instance
          .collection('reviews')
          .doc(reviewId)
          .get();

      if (reviewDoc.exists) {
        final reviewData = reviewDoc.data() as Map<String, dynamic>;
        final String destinationId = reviewData['destinationId'] ?? '';
        final double reviewRating = (reviewData['rating'] ?? 0.0).toDouble();

        // If we have a valid destination ID, update the destination's rating stats
        if (destinationId.isNotEmpty) {
          final destinationDoc = await FirebaseFirestore.instance
              .collection('destinations')
              .doc(destinationId)
              .get();

          if (destinationDoc.exists) {
            final destData = destinationDoc.data() as Map<String, dynamic>;
            final double currentAvg =
                (destData['averageRating'] ?? 0.0).toDouble();
            final int totalReviews = (destData['totalReviews'] ?? 0);

            // Only update if there are reviews
            if (totalReviews > 0) {
              // Calculate new average by removing this rating
              double newAverage = 0.0;
              if (totalReviews > 1) {
                // Remove this rating's contribution from the total and compute new average
                final double totalRatingSum = currentAvg * totalReviews;
                newAverage =
                    (totalRatingSum - reviewRating) / (totalReviews - 1);
              }

              // Update destination document
              await FirebaseFirestore.instance
                  .collection('destinations')
                  .doc(destinationId)
                  .update({
                'averageRating': newAverage,
                'totalReviews': totalReviews - 1,
              });
            }
          }
        }

        // Delete the actual review
        await FirebaseFirestore.instance
            .collection('reviews')
            .doc(reviewId)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Review deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting review: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.indigo;
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Reviews',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and filter section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search reviews...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon:
                                const Icon(Icons.clear, color: Colors.white70),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 20,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Filter options
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filterOptions.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            }
                          },
                          backgroundColor: Colors.white24,
                          selectedColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? primaryColor : Colors.white,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Review list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getReviewsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading reviews: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final reviews = _filterReviews(snapshot.data?.docs ?? []);

                // Prefetch destination names
                _prefetchDestinationNames(reviews);

                if (reviews.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.rate_review_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No reviews found'
                              : 'No reviews match your search',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    final reviewData = review.data() as Map<String, dynamic>;
                    final reviewId = review.id;

                    return _buildReviewCard(
                        reviewData, reviewId, isSmallScreen);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdminBottomMenu(
        currentIndex: _selectedIndex,
        onIndexChanged: (index) {
          if (index == _selectedIndex) return;

          switch (index) {
            case 0: // Dashboard
              Navigator.pushReplacementNamed(context, '/admin-dashboard');
              break;
            case 1: // Destinations
              Navigator.pushReplacementNamed(context, '/manage-destinations');
              break;
            case 2: // Users
              Navigator.pushReplacementNamed(context, '/manage-users');
              break;
            // Case 3 is current page (Reviews)
          }
        },
      ),
    );
  }

  // Get the stream of reviews based on selected filter
  Stream<QuerySnapshot> _getReviewsStream() {
    Query query = FirebaseFirestore.instance.collection('reviews');

    switch (_selectedFilter) {
      case 'Recent First':
        query = query.orderBy('timestamp', descending: true);
        break;
      case 'Oldest First':
        query = query.orderBy('timestamp', descending: false);
        break;
      case 'Highest Rating':
        query = query.orderBy('rating', descending: true);
        break;
      case 'Lowest Rating':
        query = query.orderBy('rating', descending: false);
        break;
      default:
        query = query.orderBy('timestamp', descending: true);
    }

    return query.snapshots();
  }

  // Filter reviews based on search query
  List<QueryDocumentSnapshot> _filterReviews(
      List<QueryDocumentSnapshot> reviews) {
    if (_searchQuery.isEmpty) {
      return reviews;
    }

    return reviews.where((review) {
      final data = review.data() as Map<String, dynamic>;
      final reviewText = (data['review'] ?? '').toString().toLowerCase();
      final userName = (data['userName'] ?? '').toString().toLowerCase();
      final destinationId =
          (data['destinationId'] ?? '').toString().toLowerCase();

      return reviewText.contains(_searchQuery) ||
          userName.contains(_searchQuery) ||
          destinationId.contains(_searchQuery);
    }).toList();
  }

  // Build a card for each review
  Widget _buildReviewCard(
      Map<String, dynamic> reviewData, String reviewId, bool isSmallScreen) {
    final String review = reviewData['review'] ?? 'No review text';
    final double rating = (reviewData['rating'] ?? 0.0).toDouble();
    final String userName = reviewData['userName'] ?? 'Anonymous';
    final Timestamp? timestamp = reviewData['timestamp'];
    final String destinationId = reviewData['destinationId'] ?? '';

    // Use a more efficient approach for destination name display
    Widget buildDestinationInfo(String destinationId) {
      if (destinationId.isEmpty) {
        return const SizedBox.shrink();
      }

      final String destinationName =
          _destinationNameCache[destinationId] ?? 'Loading...';
      final bool isLoading = !_destinationNameCache.containsKey(destinationId);
      final bool notFound = destinationName == 'Destination not found';

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: notFound ? Colors.red.shade50 : Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              isLoading
                  ? Icons.hourglass_empty
                  : (notFound ? Icons.error_outline : Icons.place),
              size: 16,
              color: notFound ? Colors.red : Colors.indigo,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                destinationName,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color:
                      notFound ? Colors.red.shade800 : Colors.indigo.shade800,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Update the Card widget with destination name fetching
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Review header with user and timestamp
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.indigo.shade100,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                    style: const TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (timestamp != null)
                        Text(
                          _formatTimestamp(timestamp),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                // Rating display
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getRatingColor(rating),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        rating.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Use the more efficient destination info widget
            buildDestinationInfo(destinationId),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Rating stars and review text
            Row(
              children: [
                RatingBar.builder(
                  initialRating: rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 20,
                  ignoreGestures: true,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (_) {},
                ),
              ],
            ),

            const SizedBox(height: 12),
            Text(
              review,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            // Destination link and action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (destinationId.isNotEmpty)
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.visibility),
                      label: const Text('View Destination'),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/destination-details',
                          arguments: destinationId,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.indigo,
                      ),
                    ),
                  ),

                const SizedBox(width: 8),

                // Delete button
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete Review'),
                  onPressed: _isLoading
                      ? null
                      : () => _showDeleteConfirmation(reviewId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(String reviewId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review?'),
        content: const Text(
          'This will permanently delete this review and update the destination rating. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteReview(reviewId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Get color based on rating
  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 3.5) return Colors.teal;
    if (rating >= 2.5) return Colors.amber;
    if (rating >= 1.5) return Colors.orange;
    return Colors.red;
  }

  // Add this method to prefetch destination data in batches
  Future<void> _prefetchDestinationNames(
      List<QueryDocumentSnapshot> reviews) async {
    if (_loadingDestinations) return;

    try {
      _loadingDestinations = true;

      // Get unique destination IDs from reviews
      final Set<String> destinationIds = reviews
          .map((review) => (review.data()
              as Map<String, dynamic>)['destinationId'] as String?)
          .where((id) =>
              id != null &&
              id.isNotEmpty &&
              !_destinationNameCache.containsKey(id))
          .toSet()
          .cast<String>();

      if (destinationIds.isEmpty) return;

      // Split into batches of 10 (Firestore limit)
      final batches = <List<String>>[];
      List<String> currentBatch = [];

      for (final id in destinationIds) {
        currentBatch.add(id);
        if (currentBatch.length == 10) {
          batches.add(currentBatch);
          currentBatch = [];
        }
      }

      if (currentBatch.isNotEmpty) {
        batches.add(currentBatch);
      }

      // Process each batch
      for (final batch in batches) {
        final snapshots = await Future.wait(
          batch.map((id) => FirebaseFirestore.instance
              .collection('destinations')
              .doc(id)
              .get()),
        );

        for (final doc in snapshots) {
          if (doc.exists) {
            final data = doc.data() as Map<String, dynamic>;
            _destinationNameCache[doc.id] =
                data['title'] ?? 'Unknown Destination';
          } else {
            _destinationNameCache[doc.id] = 'Destination not found';
          }
        }
      }
    } catch (e) {
      print('Error prefetching destination names: $e');
    } finally {
      _loadingDestinations = false;
    }
  }
}

// Format timestamp to readable date
String _formatTimestamp(Timestamp timestamp) {
  final date = timestamp.toDate();
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays == 0) {
    if (difference.inHours == 0) {
      return '${difference.inMinutes} minutes ago';
    }
    return '${difference.inHours} hours ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  } else {
    return '${date.day}/${date.month}/${date.year}';
  }
}
