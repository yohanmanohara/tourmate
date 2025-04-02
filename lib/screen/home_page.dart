import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/weather_card.dart';
import '../components/destination_card.dart';
import '../components/note_card.dart';
import '../models/destination.dart';
import '../models/note.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Enhanced dummy data with more details
 // Enhanced dummy data with more details
final List<Destination> _recommendedDestinations = [
  Destination(
    id: '1',
    title: 'San Francisco',
    description: 'Golden Gate City with iconic bridges',
    category: 'City',
    location: 'California, USA',
    features: ['Golden Gate Bridge', 'Alcatraz Island', 'Cable Cars'],
    images: ['sf.jpg'],
    averageRating: 4.7,
    reviews: 1243,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    coordinates: {'lat': 37.7749, 'lng': -122.4194},
  ),
  Destination(
    id: '2',
    title: 'Paris',
    description: 'City of Love and Lights',
    category: 'City',
    location: 'Île-de-France, France',
    features: ['Eiffel Tower', 'Louvre Museum', 'Seine River Cruise'],
    images: ['paris.jpg'],
    averageRating: 4.9,
    reviews: 2856,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    coordinates: {'lat': 48.8566, 'lng': 2.3522},
  ),
  // Add more destinations...
];

final List<Destination> _popularDestinations = [
  Destination(
    id: '3',
    title: 'Bali',
    description: 'Tropical paradise with beautiful beaches',
    category: 'Beach',
    location: 'Bali, Indonesia',
    features: ['Ubud Monkey Forest', 'Tanah Lot Temple', 'Uluwatu Cliff'],
    images: ['bali.jpg'],
    averageRating: 4.8,
    reviews: 3456,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    coordinates: {'lat': -8.3405, 'lng': 115.0920},
  ),
  // Add more destinations...
];

  final List<Note> _notes = [
    Note(
      id: '1',
      title: 'Packing List',
      content: 'Passport\nSwimsuit\nCamera\nCharger',
      color: Colors.blue[100]!,
      date: 'Today, 10:30 AM',
    ),
    Note(
      id: '2',
      title: 'Restaurants',
      content: 'Italian place near hotel\nSushi bar with good reviews',
      color: Colors.green[100]!,
      date: 'Yesterday, 4:45 PM',
    ),
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
        _notes.insert(0, Note(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          content: _contentController.text,
          color: _selectedColor,
          date: 'Just now',
        ));
      } else {
        // Update existing note
        final index = _notes.indexWhere((note) => note.id == _editingNoteId);
        if (index != -1) {
          _notes[index] = Note(
            id: _editingNoteId,
            title: _titleController.text,
            content: _contentController.text,
            color: _selectedColor,
            date: 'Updated now',
          );
        }
      }
      
      _titleController.clear();
      _contentController.clear();
      _editingNoteId = '';
      _selectedColor = Colors.blue[100]!;
    });
    
    Navigator.of(context).pop();
  }

  void _editNote(Note note) {
    _titleController.text = note.title;
    _contentController.text = note.content;
    _selectedColor = note.color;
    _editingNoteId = note.id;
    
    _showNoteDialog();
  }

  void _deleteNote(String id) {
    setState(() {
      _notes.removeWhere((note) => note.id == id);
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
                      return DestinationCard(destination: _recommendedDestinations[index]);
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
                      return NoteCard(
                        note: _notes[index],
                        onEdit: _editNote,
                        onDelete: _deleteNote,
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
                
                SizedBox(
                  height: 280,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _popularDestinations.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return DestinationCard(destination: _popularDestinations[index]);
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
}