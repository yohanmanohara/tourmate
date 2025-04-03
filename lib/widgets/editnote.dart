import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobileappdev/models/note.dart';

class EditNotePage extends StatefulWidget {
  final Note note;
  final bool isNew;

  const EditNotePage({
    Key? key,
    required this.note,
    this.isNew = false,
  }) : super(key: key);

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> with SingleTickerProviderStateMixin {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late Color _selectedColor;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Color> _colorOptions = [
    Colors.red.withOpacity(0.4),
    Colors.orange.withOpacity(0.4),
    Colors.yellow.withOpacity(0.4),
    Colors.green.withOpacity(0.4),
    Colors.blue.withOpacity(0.4),
    Colors.indigo.withOpacity(0.4),
    Colors.purple.withOpacity(0.4),
    Colors.grey.withOpacity(0.3),
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _selectedColor = widget.note.color;
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuint,
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuint,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.blue.shade50,
          appBar: _buildAppBar(),
          body: _buildAnimatedContent(),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        widget.isNew ? 'New Note' : 'Edit Note',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade800,
          fontSize: 24,
        ),
      ),
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(color: Colors.blue.shade800),
      actions: [_buildSaveButton()],
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: TextButton(
        onPressed: _saveNote,
        style: TextButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.save_rounded, size: 20),
            SizedBox(width: 8),
            Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            children: [
              _buildTitleField(),
              const SizedBox(height: 24),
              Expanded(child: _buildContentField()),
              const SizedBox(height: 24),
              _buildColorPicker(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      decoration: _buildInputDecoration(
        labelText: 'Title',
        hintText: 'Enter note title...',
      ),
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        letterSpacing: 0.2,
      ),
      maxLines: 1,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildContentField() {
    return TextField(
      controller: _contentController,
      decoration: _buildInputDecoration(
        labelText: 'Content',
        hintText: 'Write your thoughts here...',
      ),
      style: const TextStyle(
        fontSize: 16,
        height: 1.5,
        color: Colors.black87,
      ),
      maxLines: null,
      expands: true,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required String hintText,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        color: Colors.blue.shade800.withOpacity(0.6),
        fontSize: 14,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.blue.shade600,
          width: 2,
        ),
      ),
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.blue.shade800.withOpacity(0.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NOTE COLOR',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800.withOpacity(0.6),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _colorOptions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _buildColorOption(index),
          ),
        ),
      ],
    );
  }

  Widget _buildColorOption(int index) {
    return GestureDetector(
      onTap: () => _handleColorSelection(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: _colorOptions[index],
          shape: BoxShape.circle,
          border: _selectedColor == _colorOptions[index]
              ? Border.all(color: Colors.blue.shade800, width: 3)
              : null,
          boxShadow: _selectedColor == _colorOptions[index]
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _selectedColor == _colorOptions[index]
              ? Icon(Icons.check_rounded,
                  size: 24,
                  color: Colors.blue.shade800,
                  key: ValueKey(_selectedColor))
              : null,
        ),
      ),
    );
  }

  void _handleColorSelection(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedColor = _colorOptions[index];
    });
  }

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty) {
      await HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a title'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          backgroundColor: Colors.red.shade400,
          elevation: 4,
        ),
      );
      return;
    }

    final updatedNote = Note(
      id: widget.note.id,
      title: _titleController.text,
      content: _contentController.text,
      color: _selectedColor,
      date: DateFormat('MMM d, yyyy').format(DateTime.now()),
    );

    if (mounted) {
      Navigator.pop(context, updatedNote);
    }
  }
}