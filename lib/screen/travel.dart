import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/travel_card.dart';
import '../models/destination.dart';

class TravelPage extends StatefulWidget {
  const TravelPage({super.key});

  @override
  State<TravelPage> createState() => _TravelPageState();
}

class _TravelPageState extends State<TravelPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Destination> allDestinations = [];
  String searchQuery = '';
  String selectedCategory = 'All';
  List<Destination> filteredDestinations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDestinations();
  }

  Future<void> _fetchDestinations() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('destinations').get();

      List<Destination> loadedDestinations = [];
      for (var doc in snapshot.docs) {
        loadedDestinations.add(Destination.fromFirestore(doc));
      }

      setState(() {
        allDestinations = loadedDestinations;
        filteredDestinations = loadedDestinations;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error (you might want to show a snackbar or alert)
      debugPrint('Error fetching destinations: $e');
    }
  }

  void _filterDestinations() {
    setState(() {
      filteredDestinations = allDestinations.where((destination) {
        final matchesSearch = destination.title
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            destination.location
                .toLowerCase()
                .contains(searchQuery.toLowerCase());
        final matchesCategory = selectedCategory == 'All' ||
            destination.category.toLowerCase() ==
                selectedCategory.toLowerCase();
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  // Navigate to destination details screen
  void _navigateToDetails(String destinationId) {
    Navigator.pushNamed(
      context,
      '/user-destination-details',
      arguments: destinationId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = isTablet ? 24.0 : 16.0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(30),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 8,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search destinations...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                      _filterDestinations();
                    });
                  },
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 8,
            ),
            sliver: SliverToBoxAdapter(
              child: SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryChip('All', Icons.public),
                    _buildCategoryChip('Urban', Icons.location_city),
                    _buildCategoryChip('Beach', Icons.beach_access),
                    _buildCategoryChip('Nature', Icons.forest),
                    _buildCategoryChip('Cultural', Icons.account_balance),
                    _buildCategoryChip('Historical', Icons.history),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (filteredDestinations.isNotEmpty)
            _buildDestinationGrid(horizontalPadding, isTablet)
          else
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.travel_explore,
                      size: 64,
                      color: theme.disabledColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No destinations found',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.disabledColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try adjusting your search or filters',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.disabledColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDestinationGrid(double horizontalPadding, bool isTablet) {
    if (isTablet) {
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return DestinationCard(
                destination: filteredDestinations[index],
                initialHeight: 180,
                onExplorePressed: () =>
                    _navigateToDetails(filteredDestinations[index].id ?? ''),
              );
            },
            childCount: filteredDestinations.length,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DestinationCard(
                destination: filteredDestinations[index],
                initialHeight: 200,
                onExplorePressed: () =>
                    _navigateToDetails(filteredDestinations[index].id ?? ''),
              ),
            );
          },
          childCount: filteredDestinations.length,
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category, IconData icon) {
    final isSelected = selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 4),
            Text(category),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedCategory = selected ? category : 'All';
            _filterDestinations();
          });
        },
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
        labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurface,
            ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        showCheckmark: false,
        avatarBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
