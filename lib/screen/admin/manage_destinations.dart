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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Destinations',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort destinations',
            onPressed: () {
              _showSortOptionsDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter by category',
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search destinations...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Category filter chips
          if (!isSmallScreen)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: _filterCategory == category,
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

          // Destinations list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: destinationsRef
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_off,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'No destinations found',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add your first destination'),
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
                        const Text('No matching destinations found'),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          child: const Text('Clear filters'),
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
                      elevation: 2, // Lower elevation for modern flat design
                      margin: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16), // More rounded corners
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
                            borderRadius:
                                BorderRadius.circular(16), // Match card shape
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
                                                    width: isNarrow ? 60 : 80,
                                                    height: isNarrow ? 60 : 80,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (_, __, ___) =>
                                                            Container(
                                                      width: isNarrow ? 60 : 80,
                                                      height:
                                                          isNarrow ? 60 : 80,
                                                      color: Colors.grey[200],
                                                      child: Icon(
                                                          Icons
                                                              .image_not_supported,
                                                          size: 24,
                                                          color:
                                                              Colors.grey[500]),
                                                    ),
                                                  ),
                                                  // Optional: Add a subtle gradient overlay for better text contrast
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
                                                          color: Colors.blue
                                                              .withOpacity(0.8),
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
                                                                  Colors.white,
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
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: isNarrow
                                                              ? 16
                                                              : 18,
                                                          color: Colors
                                                              .blueGrey[800],
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
                                                        color: Colors.blueGrey,
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
                                                        color: Colors.blue
                                                            .withOpacity(0.15),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50),
                                                        border: Border.all(
                                                          color: Colors.blue
                                                              .withOpacity(0.3),
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        data['category'] ??
                                                            'Uncategorized',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Colors.blue[700],
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
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          data['description'] ??
                                              'No description available',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.blueGrey[700],
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
                                                color: Colors.blueGrey[600],
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
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
                                              foregroundColor: Colors.blue[700],
                                              side: BorderSide(
                                                  color: Colors.blue.shade300),
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
                                              backgroundColor: Colors.blue,
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
            child: const Text('Newest First'),
          ),
          SimpleDialogOption(
            onPressed: () {
              // Implement sorting logic
              Navigator.pop(context);
            },
            child: const Text('Oldest First'),
          ),
          SimpleDialogOption(
            onPressed: () {
              // Implement sorting logic
              Navigator.pop(context);
            },
            child: const Text('Name (A-Z)'),
          ),
          SimpleDialogOption(
            onPressed: () {
              // Implement sorting logic
              Navigator.pop(context);
            },
            child: const Text('Name (Z-A)'),
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
