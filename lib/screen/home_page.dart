import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final CollectionReference destinationsCollection =
      FirebaseFirestore.instance.collection('destinations');
  final CollectionReference notesCollection =
      FirebaseFirestore.instance.collection('notes');
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  List<String> _userPreferences = [];
  late Future<void> _preferencesFuture;
  late Future<List<Destination>> _recommendedDestinationsFuture;
  late Future<List<Destination>> _popularDestinationsFuture;
  late Future<List<Note>> _notesFuture;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  Color _selectedColor = Colors.blue[100]!;
  String _editingNoteId = '';

  @override
  void initState() {
    super.initState();
    _preferencesFuture = _fetchUserPreferences().then((_) {
      _loadData();
    });
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
    _notesFuture = _fetchNotes();
  }

  Future<List<Destination>> _fetchRecommendedDestinations() async {
    try {
      Query query = destinationsCollection;
      
      // Filter by user preferences if they exist
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

  Future<List<Note>> _fetchNotes() async {
    try {
      final querySnapshot = await notesCollection
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Note(
          id: doc.id,
          title: data['title'] ?? '',
          content: data['content'] ?? '',
          color: _colorFromString(data['color'] ?? 'blue'),
          date: DateFormat('MMM d, h:mm a').format(
              (data['createdAt'] as Timestamp).toDate()),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching notes: $e');
      return [];
    }
  }

  Color _colorFromString(String colorName) {
    switch (colorName) {
      case 'blue':
        return Colors.blue[100]!;
      case 'green':
        return Colors.green[100]!;
      case 'yellow':
        return Colors.yellow[100]!;
      case 'red':
        return Colors.red[100]!;
      case 'purple':
        return Colors.purple[100]!;
      case 'orange':
        return Colors.orange[100]!;
      default:
        return Colors.blue[100]!;
    }
  }

  String _colorToString(Color color) {
    if (color == Colors.blue[100]) return 'blue';
    if (color == Colors.green[100]) return 'green';
    if (color == Colors.yellow[100]) return 'yellow';
    if (color == Colors.red[100]) return 'red';
    if (color == Colors.purple[100]) return 'purple';
    if (color == Colors.orange[100]) return 'orange';
    return 'blue';
  }

  Future<void> _addOrUpdateNote() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) return;

    try {
      final noteData = {
        'title': _titleController.text,
        'content': _contentController.text,
        'color': _colorToString(_selectedColor),
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      if (_editingNoteId.isEmpty) {
        await notesCollection.add(noteData);
      } else {
        await notesCollection.doc(_editingNoteId).update(noteData);
      }

      _titleController.clear();
      _contentController.clear();
      _editingNoteId = '';
      _selectedColor = Colors.blue[100]!;

      setState(() {
        _notesFuture = _fetchNotes();
      });
    } catch (e) {
      debugPrint('Error saving note: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save note: $e')),
      );
    }

    Navigator.of(context).pop();
  }

  void _editNote(Note note) {
    _titleController.text = note.title;
    _contentController.text = note.content;
    _selectedColor = note.color;
    _editingNoteId = note.id;
    _showNoteDialog();
  }

  Future<void> _deleteNote(String id) async {
    try {
      await notesCollection.doc(id).delete();
      setState(() {
        _notesFuture = _fetchNotes();
      });
    } catch (e) {
      debugPrint('Error deleting note: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete note: $e')),
      );
    }
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
        child: FutureBuilder<void>(
          future: _preferencesFuture,
          builder: (context, preferencesSnapshot) {
            if (preferencesSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (preferencesSnapshot.hasError) {
              return Center(child: Text('Error loading preferences: ${preferencesSnapshot.error}'));
            }
            
            return SingleChildScrollView(
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
                    
                    FutureBuilder<List<Note>>(
                      future: _notesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        
                        final notes = snapshot.data ?? [];
                        
                        if (notes.isEmpty) {
                          return Container(
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
                          );
                        }
                        
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.2,
                          ),
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            return NoteCard(
                              note: notes[index],
                              onEdit: _editNote,
                              onDelete: _deleteNote,
                            );
                          },
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
            );
          },
        ),
      ),
    );
  }
}