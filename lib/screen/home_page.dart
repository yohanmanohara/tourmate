import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Enhanced dummy data with more details
  final List<Map<String, dynamic>> _recommendedDestinations = [
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
    // ... (keep other recommended destinations)
  ];

  final List<Map<String, dynamic>> _popularDestinations = [
    {
      'name': 'Bali',
      'image': 'bali.jpg',
      'currentTemp': '28°C',
      'highTemp': '32°C',
      'lowTemp': '26°C',
      'price': '\$150/night',
      'rating': 4.8,
      'reviews': 3456,
      'description': 'Tropical paradise with beautiful beaches',
      'activities': ['Ubud', 'Tanah Lot', 'Uluwatu'],
      'deal': 'All inclusive',
      'dealColor': Colors.pink,
    },
      {
      'name': 'Bali',
      'image': 'bali.jpg',
      'currentTemp': '28°C',
      'highTemp': '32°C',
      'lowTemp': '26°C',
      'price': '\$150/night',
      'rating': 4.8,
      'reviews': 3456,
      'description': 'Tropical paradise with beautiful beaches',
      'activities': ['Ubud', 'Tanah Lot', 'Uluwatu'],
      'deal': 'All inclusive',
      'dealColor': Colors.pink,
    },  {
      'name': 'Bali',
      'image': 'bali.jpg',
      'currentTemp': '28°C',
      'highTemp': '32°C',
      'lowTemp': '26°C',
      'price': '\$150/night',
      'rating': 4.8,
      'reviews': 3456,
      'description': 'Tropical paradise with beautiful beaches',
      'activities': ['Ubud', 'Tanah Lot', 'Uluwatu'],
      'deal': 'All inclusive',
      'dealColor': Colors.pink,
    },
    // ... (keep other popular destinations)
  ];

  // Notes functionality
  final List<Map<String, dynamic>> _notes = [
    {
      'id': '1',
      'title': 'Packing List',
      'content': 'Passport\nSwimsuit\nCamera\nCharger',
      'color': Colors.blue[100],
      'date': 'Today, 10:30 AM',
    },
    {
      'id': '2',
      'title': 'Restaurants',
      'content': 'Italian place near hotel\nSushi bar with good reviews',
      'color': Colors.green[100],
      'date': 'Yesterday, 4:45 PM',
    },
  ];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  Color _selectedColor = Colors.blue[100]!;
  String _editingNoteId = '';

  void _addOrUpdateNote() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) return;

    setState(() {
      if (_editingNoteId.isEmpty) {
        // Add new note
        _notes.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'title': _titleController.text,
          'content': _contentController.text,
          'color': _selectedColor,
          'date': 'Just now',
        });
      } else {
        // Update existing note
        final index = _notes.indexWhere((note) => note['id'] == _editingNoteId);
        if (index != -1) {
          _notes[index] = {
            'id': _editingNoteId,
            'title': _titleController.text,
            'content': _contentController.text,
            'color': _selectedColor,
            'date': 'Updated now',
          };
        }
      }
      
      _titleController.clear();
      _contentController.clear();
      _editingNoteId = '';
      _selectedColor = Colors.blue[100]!;
    });
    
    Navigator.of(context).pop();
  }

  void _editNote(Map<String, dynamic> note) {
    _titleController.text = note['title'];
    _contentController.text = note['content'];
    _selectedColor = note['color'];
    _editingNoteId = note['id'];
    
    _showNoteDialog();
  }

  void _deleteNote(String id) {
    setState(() {
      _notes.removeWhere((note) => note['id'] == id);
    });
  }

  void _showNoteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_editingNoteId.isEmpty ? 'Add New Note' : 'Edit Note'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildColorOption(Colors.blue[100]!),
                      _buildColorOption(Colors.green[100]!),
                      _buildColorOption(Colors.yellow[100]!),
                      _buildColorOption(Colors.red[100]!),
                      _buildColorOption(Colors.purple[100]!),
                      _buildColorOption(Colors.orange[100]!),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _addOrUpdateNote,
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildColorOption(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: _selectedColor == color
              ? Border.all(color: Colors.black, width: 2)
              : null,
        ),
      ),
    );
  }

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
            
                // Recommended destinations section
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
                  'Personalized picks based on your preferences',
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
                    itemCount: _recommendedDestinations.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final destination = _recommendedDestinations[index];
                      return TravelDestinationCard(destination: destination);
                    },
                  ),
                ),

                // Notes section
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Travel Notes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _showNoteDialog,
                      tooltip: 'Add new note',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Keep your travel plans organized',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                
                if (_notes.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'No notes yet. Tap the + button to add one!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      return _buildNoteCard(note);
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
                
                SizedBox(
                  height: 280,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _popularDestinations.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final destination = _popularDestinations[index];
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

  Widget _buildNoteCard(Map<String, dynamic> note) {
    return GestureDetector(
      onTap: () => _editNote(note),
      child: Container(
        decoration: BoxDecoration(
          color: note['color'],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  note['content'],
                  style: const TextStyle(fontSize: 14),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Text(
                  note['date'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.delete, size: 18),
                onPressed: () => _deleteNote(note['id']),
                color: Colors.grey[700],
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
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