import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
                      child: Column(
                        children: [
                          // Main card content
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (_expandedItems.contains(doc.id)) {
                                  _expandedItems.remove(doc.id);
                                } else {
                                  _expandedItems.add(doc.id);
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  // Responsive layout based on available width
                                  final isNarrow = constraints.maxWidth < 400;

                                  return Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Leading image
                                          Hero(
                                            tag: 'destination-${doc.id}',
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Stack(
                                                children: [
                                                  Image.network(
                                                    data['images']?[0] ?? '',
                                                    width: isNarrow ? 70 : 90,
                                                    height: isNarrow ? 70 : 90,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (_, __, ___) =>
                                                            Container(
                                                      width: isNarrow ? 70 : 90,
                                                      height:
                                                          isNarrow ? 70 : 90,
                                                      color: Colors.grey[200],
                                                      child: const Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        size: 24,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                  // Rating badge
                                                  if (data['averageRating'] !=
                                                      null)
                                                    Positioned(
                                                      top: 0,
                                                      right: 0,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.indigo
                                                              .withOpacity(
                                                                  0.85),
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    8),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            const Icon(
                                                              Icons.star,
                                                              size: 14,
                                                              color:
                                                                  Colors.amber,
                                                            ),
                                                            const SizedBox(
                                                                width: 2),
                                                            Text(
                                                              '${(data['averageRating'] as num? ?? 0).toStringAsFixed(1)}',
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
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
                                          const SizedBox(width: 16),

                                          // Destination details
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Title row with actions
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Title
                                                    Expanded(
                                                      child: Text(
                                                        data['title'] ??
                                                            'Unknown',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 17,
                                                          color: Colors.indigo,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 2,
                                                      ),
                                                    ),

                                                    // Actions menu
                                                    PopupMenuButton<String>(
                                                      icon: const Icon(
                                                        Icons.more_vert,
                                                        color: Colors.grey,
                                                      ),
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
                                                      itemBuilder: (context) =>
                                                          [
                                                        const PopupMenuItem(
                                                          value: 'preview',
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .visibility,
                                                                  size: 20),
                                                              SizedBox(
                                                                  width: 8),
                                                              Text('Preview'),
                                                            ],
                                                          ),
                                                        ),
                                                        const PopupMenuItem(
                                                          value: 'edit',
                                                          child: Row(
                                                            children: [
                                                              Icon(Icons.edit,
                                                                  size: 20),
                                                              SizedBox(
                                                                  width: 8),
                                                              Text('Edit'),
                                                            ],
                                                          ),
                                                        ),
                                                        const PopupMenuItem(
                                                          value: 'delete',
                                                          child: Row(
                                                            children: [
                                                              Icon(Icons.delete,
                                                                  size: 20,
                                                                  color: Colors
                                                                      .red),
                                                              SizedBox(
                                                                  width: 8),
                                                              Text('Delete',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red)),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 8),

                                                // Metadata row (category & date)
                                                Wrap(
                                                  spacing: 8,
                                                  runSpacing: 8,
                                                  crossAxisAlignment:
                                                      WrapCrossAlignment.center,
                                                  children: [
                                                    // Category chip
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.indigo
                                                            .withOpacity(0.15),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50),
                                                      ),
                                                      child: Text(
                                                        data['category'] ??
                                                            'Uncategorized',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.indigo,
                                                        ),
                                                      ),
                                                    ),

                                                    // Date
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.calendar_today,
                                                          size: 12,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          formattedDate,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .grey[700],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Expansion indicator with animation
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        margin: EdgeInsets.only(
                                          top: _expandedItems.contains(doc.id)
                                              ? 12
                                              : 8,
                                        ),
                                        child: Icon(
                                          _expandedItems.contains(doc.id)
                                              ? Icons.keyboard_arrow_up_rounded
                                              : Icons
                                                  .keyboard_arrow_down_rounded,
                                          color: Colors.grey[500],
                                          size: 24,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),

                          // Expanded details with animation
                          AnimatedCrossFade(
                            firstChild: const SizedBox(height: 0),
                            secondChild: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Subtle divider
                                  Divider(color: Colors.grey[300], height: 1),

                                  // Description
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 16, 16, 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Description',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.indigo,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          data['description'] ??
                                              'No description available',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[800],
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Location information (if available)
                                  if (data['location'] != null)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 8, 16, 8),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 16,
                                            color: Colors.orange[700],
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              data['location'],
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[800],
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // Features (if available)
                                  if (data['features'] != null &&
                                      (data['features'] as List).isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 8, 16, 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Features',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: (data['features'] as List)
                                                .map<Widget>((feature) {
                                              return Chip(
                                                label: Text(
                                                  feature,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                backgroundColor:
                                                    Colors.grey[100],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                visualDensity:
                                                    VisualDensity.compact,
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // Action buttons
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            icon: const Icon(
                                                Icons.visibility_outlined),
                                            label: const Text('Preview'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.indigo,
                                              side: const BorderSide(
                                                  color: Colors.indigo),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 12,
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                context,
                                                '/destination-details',
                                                arguments: doc.id,
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            icon:
                                                const Icon(Icons.edit_outlined),
                                            label: const Text('Edit'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.indigo,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 12,
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                context,
                                                '/edit-destination',
                                                arguments: doc.id,
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            crossFadeState: _expandedItems.contains(doc.id)
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 300),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/edit-destination');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Destination'),
        tooltip: 'Add New Destination',
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
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
