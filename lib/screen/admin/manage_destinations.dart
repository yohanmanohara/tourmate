import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/admin_bottom_menu.dart';

class ManageDestinationsScreen extends StatefulWidget {
  const ManageDestinationsScreen({Key? key}) : super(key: key);

  @override
  State<ManageDestinationsScreen> createState() =>
      _ManageDestinationsScreenState();
}

class _ManageDestinationsScreenState extends State<ManageDestinationsScreen> {
  String _searchQuery = '';
  String _filterCategory = 'All';
  bool _isLoading = false;
  final List<String> _categories = [
    'All',
    'Historical',
    'Nature',
    'Cultural',
    'Urban',
    'Adventure'
  ];
  final Set<String> _expandedItems = {};
  int _selectedIndex = 1; // Set to 1 for Destinations tab

  @override
  Widget build(BuildContext context) {
    final destinationsRef =
        FirebaseFirestore.instance.collection('destinations');
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Destinations',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.white),
            tooltip: 'Sort destinations',
            onPressed: () {
              _showSortOptionsDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            tooltip: 'Filter by category',
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats and search bar container
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and search bar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search destinations...',
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    StreamBuilder<QuerySnapshot>(
                      stream: destinationsRef.snapshots(),
                      builder: (context, snapshot) {
                        final count =
                            snapshot.hasData ? snapshot.data!.docs.length : 0;
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$count',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.indigo,
                                ),
                              ),
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.indigo,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                // Category filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = _filterCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          showCheckmark: false,
                          backgroundColor: Colors.grey[100],
                          selectedColor: Colors.indigo.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.indigo : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          side: BorderSide(
                            color:
                                isSelected ? Colors.indigo : Colors.transparent,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _filterCategory = selected ? category : 'All';
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Destinations list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: destinationsRef
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_off,
                            size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'No destinations found',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Get started by adding your first destination',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add Destination'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/edit-destination');
                          },
                        ),
                      ],
                    ),
                  );
                }

                // Filter destinations
                final allDestinations = snapshot.data!.docs;
                final filteredDestinations = allDestinations.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title = (data['title'] ?? '').toString().toLowerCase();
                  final description =
                      (data['description'] ?? '').toString().toLowerCase();
                  final category = data['category'] ?? '';

                  // Apply search filter
                  final matchesSearch = _searchQuery.isEmpty ||
                      title.contains(_searchQuery) ||
                      description.contains(_searchQuery);

                  // Apply category filter
                  final matchesCategory =
                      _filterCategory == 'All' || category == _filterCategory;

                  return matchesSearch && matchesCategory;
                }).toList();

                if (filteredDestinations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'No matching destinations found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear filters'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.withOpacity(0.1),
                            foregroundColor: Colors.indigo,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _filterCategory = 'All';
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDestinations.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDestinations[index];
                    final data = doc.data() as Map<String, dynamic>;

                    // Format date (if available)
                    String formattedDate = '';
                    if (data['createdAt'] != null) {
                      try {
                        final timestamp = data['createdAt'] as Timestamp;
                        formattedDate = DateFormat('MMM d, yyyy')
                            .format(timestamp.toDate());
                      } catch (e) {
                        formattedDate = 'Date unknown';
                      }
                    }

                    // Updated destination card UI without redundant buttons

                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias, // Prevent child overflow
                      child: InkWell(
                        // Navigate to destination details on tap
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/destination-details',
                            arguments: doc.id,
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 10 : 16,
                            vertical: isSmallScreen ? 12 : 16,
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Responsive layout based on available width
                              final bool isNarrow = constraints.maxWidth < 400;
                              final double imageSize =
                                  isSmallScreen ? 60 : (isNarrow ? 70 : 80);

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Leading image with improved loading and error handling
                                  Hero(
                                    tag: 'destination-${doc.id}',
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        width: imageSize,
                                        height: imageSize,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            // Image or placeholder
                                            data['images'] != null &&
                                                    (data['images'] as List)
                                                        .isNotEmpty
                                                ? Image.network(
                                                    data['images'][0],
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (context,
                                                        child,
                                                        loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) return child;
                                                      return Container(
                                                        color: Colors.grey[200],
                                                        child: Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                            value: loadingProgress
                                                                        .expectedTotalBytes !=
                                                                    null
                                                                ? loadingProgress
                                                                        .cumulativeBytesLoaded /
                                                                    loadingProgress
                                                                        .expectedTotalBytes!
                                                                : null,
                                                            strokeWidth: 2,
                                                            color: Colors.indigo
                                                                .withOpacity(
                                                                    0.5),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    errorBuilder:
                                                        (_, __, ___) =>
                                                            Container(
                                                      color: Colors.grey[200],
                                                      child: Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        size: imageSize / 3,
                                                        color: Colors.grey[400],
                                                      ),
                                                    ),
                                                  )
                                                : Container(
                                                    color: Colors.grey[200],
                                                    child: Icon(
                                                      Icons.photo_outlined,
                                                      size: imageSize / 3,
                                                      color: Colors.grey[400],
                                                    ),
                                                  ),

                                            // Rating badge with improved position
                                            if (data['averageRating'] != null)
                                              Positioned(
                                                bottom: 0,
                                                right: 0,
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.amber
                                                        .withOpacity(0.9),
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(8),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Icon(
                                                        Icons.star,
                                                        size: 12,
                                                        color: Colors.white,
                                                      ),
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        '${(data['averageRating'] as num? ?? 0).toStringAsFixed(1)}',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: isSmallScreen ? 10 : 14),

                                  // Content column with improved spacing and layout
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Title and action row with better alignment
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Title with overflow protection
                                            Expanded(
                                              child: Text(
                                                data['title'] ??
                                                    'Unknown Destination',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      isSmallScreen ? 14 : 16,
                                                  color: Colors.indigo,
                                                  height: 1.2,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ),

                                            // More compact menu
                                            SizedBox(
                                              height: 36,
                                              width: 30,
                                              child: PopupMenuButton<String>(
                                                icon: const Icon(
                                                  Icons.more_vert,
                                                  color: Colors.grey,
                                                  size: 20,
                                                ),
                                                padding: EdgeInsets.zero,
                                                splashRadius: 20,
                                                position:
                                                    PopupMenuPosition.under,
                                                onSelected: (value) {
                                                  if (value == 'edit') {
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/edit-destination',
                                                      arguments: doc.id,
                                                    );
                                                  } else if (value ==
                                                      'delete') {
                                                    _confirmDelete(
                                                      context,
                                                      doc.id,
                                                      destinationsRef,
                                                    );
                                                  } else if (value ==
                                                      'preview') {
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/destination-details',
                                                      arguments: doc.id,
                                                    );
                                                  }
                                                },
                                                itemBuilder: (context) => [
                                                  const PopupMenuItem(
                                                    value: 'preview',
                                                    height: 40,
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.visibility,
                                                            size: 18),
                                                        SizedBox(width: 8),
                                                        Text('Preview',
                                                            style: TextStyle(
                                                                fontSize: 14)),
                                                      ],
                                                    ),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'edit',
                                                    height: 40,
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.edit,
                                                            size: 18),
                                                        SizedBox(width: 8),
                                                        Text('Edit',
                                                            style: TextStyle(
                                                                fontSize: 14)),
                                                      ],
                                                    ),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'delete',
                                                    height: 40,
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.delete,
                                                            size: 18,
                                                            color: Colors.red),
                                                        SizedBox(width: 8),
                                                        Text('Delete',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize: 14)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Brief description with proper spacing
                                        if (data['description'] != null &&
                                            data['description']
                                                .toString()
                                                .isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 4, bottom: 6),
                                            child: Text(
                                              data['description'],
                                              style: TextStyle(
                                                fontSize:
                                                    isSmallScreen ? 12 : 13,
                                                color: Colors.grey[800],
                                                height: 1.3,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),

                                        // Location row with improved icon placement
                                        if (data['location'] != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  size: isSmallScreen ? 12 : 14,
                                                  color: Colors.grey[600],
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    data['location'],
                                                    style: TextStyle(
                                                      fontSize: isSmallScreen
                                                          ? 11
                                                          : 12,
                                                      color: Colors.grey[700],
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                        // Metadata row with better stacking for small screens
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 4,
                                          alignment: WrapAlignment.start,
                                          children: [
                                            // Category chip with improved style
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    isSmallScreen ? 6 : 8,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.indigo
                                                    .withOpacity(0.15),
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              child: Text(
                                                data['category'] ??
                                                    'Uncategorized',
                                                style: TextStyle(
                                                  fontSize:
                                                      isSmallScreen ? 9 : 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.indigo,
                                                ),
                                              ),
                                            ),

                                            // Date with correct vertical alignment
                                            if (formattedDate.isNotEmpty)
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      isSmallScreen ? 6 : 8,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.calendar_today,
                                                      size: isSmallScreen
                                                          ? 9
                                                          : 10,
                                                      color: Colors.grey[600],
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      formattedDate,
                                                      style: TextStyle(
                                                        fontSize: isSmallScreen
                                                            ? 9
                                                            : 11,
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Replace the existing floatingActionButton with our consistent bottom menu pattern
      bottomNavigationBar: AdminBottomMenu(
        currentIndex: _selectedIndex,
        onIndexChanged: (index) {
          if (index == _selectedIndex) return;

          switch (index) {
            case 0: // Dashboard
              Navigator.pushReplacementNamed(context, '/admin-dashboard');
              break;
            case 1: // Already on Destinations
              break;
            case 2: // Users
              Navigator.pushReplacementNamed(context, '/manage-users');
              break;
            case 3: // Analytics
              Navigator.pushReplacementNamed(context, '/analytics');
              break;
          }
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/edit-destination');
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add New Destination',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Future<void> _confirmDelete(BuildContext context, String docId,
      CollectionReference destinationsRef) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Destination'),
        content: const Text(
            'Are you sure you want to delete this destination? This action cannot be undone.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await destinationsRef.doc(docId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Destination successfully deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting destination: $e'),
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
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Category'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: _categories.map((category) {
              return RadioListTile<String>(
                title: Text(category),
                value: category,
                activeColor: Colors.indigo,
                groupValue: _filterCategory,
                onChanged: (value) {
                  setState(() {
                    _filterCategory = value!;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showSortOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Sort Destinations'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              // Implement sorting logic
              Navigator.pop(context);
            },
            child: const Row(
              children: [
                Icon(Icons.arrow_downward, size: 20, color: Colors.indigo),
                SizedBox(width: 12),
                Text('Newest First'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              // Implement sorting logic
              Navigator.pop(context);
            },
            child: const Row(
              children: [
                Icon(Icons.arrow_upward, size: 20, color: Colors.indigo),
                SizedBox(width: 12),
                Text('Oldest First'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              // Implement sorting logic
              Navigator.pop(context);
            },
            child: const Row(
              children: [
                Icon(Icons.sort_by_alpha, size: 20, color: Colors.indigo),
                SizedBox(width: 12),
                Text('Name (A-Z)'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              // Implement sorting logic
              Navigator.pop(context);
            },
            child: const Row(
              children: [
                Icon(Icons.sort_by_alpha, size: 20, color: Colors.indigo),
                SizedBox(width: 12),
                Text('Name (Z-A)'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
