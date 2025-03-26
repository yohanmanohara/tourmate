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
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        leading: Hero(
                          tag: 'destination-${doc.id}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              data['images']?[0] ?? '',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: Icon(Icons.image_not_supported,
                                    color: Colors.grey[600]),
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          data['title'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    data['category'] ?? 'Uncategorized',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.calendar_today,
                                    size: 12, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              tooltip: 'Edit destination',
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/edit-destination',
                                  arguments: doc.id,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete destination',
                              onPressed: () => _confirmDelete(
                                  context, doc.id, destinationsRef),
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['description'] ??
                                    'No description available'),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    OutlinedButton.icon(
                                      icon: const Icon(Icons.visibility),
                                      label: const Text('Preview'),
                                      onPressed: () {
                                        // Navigate to destination preview
                                        Navigator.pushNamed(
                                          context,
                                          '/destination-details',
                                          arguments: doc.id,
                                        );
                                      },
                                    ),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.edit),
                                      label: const Text('Edit Details'),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/edit-destination',
                                          arguments: doc.id,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
