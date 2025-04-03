import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/weather_card.dart';
import '../components/destination_card.dart';
import '../components/note_card.dart';
import '../models/destination.dart';
import '../models/note.dart';
import '../widgets/editnote.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Firestore collections
  final CollectionReference destinationsCollection =
      FirebaseFirestore.instance.collection('destinations');
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference notesCollection =
      FirebaseFirestore.instance.collection('notes');

  // State variables
  List<String> _userPreferences = [];
  late Future<void> _preferencesFuture;
  late Future<List<Destination>> _recommendedDestinationsFuture;
  late Future<List<Destination>> _popularDestinationsFuture;
  late Future<List<Note>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _preferencesFuture = _fetchUserPreferences().then((_) {
      _loadDestinationData();
    });
    _notesFuture = _fetchUserNotes();
  }

  // Data fetching methods
  Future<void> _fetchUserPreferences() async {
    try {
      final userDoc = await usersCollection.doc('current_user_id').get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _userPreferences = List<String>.from(data['preferences'] ?? []);
        });
      }
    } catch (e) {
      debugPrint('Error fetching preferences: $e');
    }
  }

  Future<List<Note>> _fetchUserNotes() async {
    try {
      final querySnapshot = await notesCollection
          .where('userId', isEqualTo: 'current_user_id')
          .orderBy('date', descending: true)
          .limit(3)
          .get();
      return querySnapshot.docs
          .map((doc) => Note.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching notes: $e');
      return [];
    }
  }

  void _loadDestinationData() {
    setState(() {
      _recommendedDestinationsFuture = _fetchRecommendedDestinations();
      _popularDestinationsFuture = _fetchPopularDestinations();
    });
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
      return querySnapshot.docs.map(Destination.fromFirestore).toList();
    } catch (e) {
      debugPrint('Error fetching recommended: $e');
      return [];
    }
  }

 Future<List<Destination>> _fetchPopularDestinations() async {
  try {
    debugPrint('Fetching popular destinations...');
    final querySnapshot = await destinationsCollection
        .orderBy('averageRating', descending: true)
        .limit(5)
        .get();

    debugPrint('Found ${querySnapshot.docs.length} destinations');
    if (querySnapshot.docs.isEmpty) {
      debugPrint('No documents found in destinations collection');
    } else {
      for (var doc in querySnapshot.docs) {
        debugPrint('Doc ${doc.id} - averageRating: ${doc['averageRating']}');
      }
    }

    return querySnapshot.docs.map(Destination.fromFirestore).toList();
  } catch (e) {
    debugPrint('Error fetching popular destinations: $e');
    return [];
  }
}
  // Note CRUD operations
  Future<void> _saveNoteToFirestore(Note note) async {
    try {
      await notesCollection.doc(note.id).set(note.toMap());
      if (mounted) {
        setState(() {
          _notesFuture = _fetchUserNotes();
        });
      }
    } catch (e) {
      debugPrint('Error saving note: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving note: $e')),
        );
      }
    }
  }

  Future<void> _deleteNote(String id) async {
    try {
      await notesCollection.doc(id).delete();
      if (mounted) {
        setState(() {
          _notesFuture = _fetchUserNotes();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting note: $e')),
        );
      }
    }
  }

  // UI Helper methods
  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildSectionHeader(String title, String? subtitle, {VoidCallback? onAction, IconData? actionIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (onAction != null && actionIcon != null)
              IconButton(
                icon: Icon(actionIcon),
                onPressed: onAction,
              ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDestinationsList(Future<List<Destination>> future) {
    return FutureBuilder<List<Destination>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        
        final destinations = snapshot.data ?? [];
        
        if (destinations.isEmpty) {
          return const Center(child: Text('No destinations found'));
        }
        
        return SizedBox(
          height: 430,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: destinations.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: DestinationCard(destination: destinations[index]),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNotesSection() {
    return FutureBuilder<List<Note>>(
      future: _notesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final notes = snapshot.data ?? [];
        
        if (notes.isEmpty) {
          return NoteCard(
            note: Note(
              id: 'default',
              title: 'No notes yet',
              content: 'Tap + to create your first travel note',
              color: Colors.grey[200]!,
              date: 'Now',
            ),
            onEdit: (_) => _createNewNote(context),
            showDeleteButton: false,
          );
        }
        
        return Column(
          children: notes.map((note) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: NoteCard(
              note: note,
              onEdit: (note) => _editNote(context, note),
              onDelete: _deleteNote,
            ),
          )).toList(),
        );
      },
    );
  }

  // Navigation methods
  Future<void> _createNewNote(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNotePage(
          note: Note(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: '',
            content: '',
            color: Colors.blue[100]!,
            date: DateFormat('MMM d').format(DateTime.now()),
          ),
          isNew: true,
        ),
      ),
    );

    if (result != null && result is Note) {
      await _saveNoteToFirestore(result);
    }
  }

  Future<void> _editNote(BuildContext context, Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNotePage(note: note),
      ),
    );

    if (result != null && result is Note) {
      await _saveNoteToFirestore(result);
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
            
            return RefreshIndicator(
              onRefresh: () async {
                setState(_initializeData);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
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
                      const WeatherCard(),

                      // Notes Section
                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        'Your Travel Notes',
                        null,
                        onAction: () => _createNewNote(context),
                        actionIcon: Icons.add_box_rounded,
                      ),
                      _buildNotesSection(),

                      // Recommended destinations
                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        'Recommended For You',
                        _userPreferences.isNotEmpty
                            ? 'Based on your preferences: ${_userPreferences.join(', ')}'
                            : 'Popular destinations you might like',
                      ),
                      _buildDestinationsList(_recommendedDestinationsFuture),

                      // Popular destinations
                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        'Top Rated Destinations',
                        'Highest rated destinations travelers love',
                      ),
                      _buildDestinationsList(_popularDestinationsFuture),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewNote(context),
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}