import 'package:flutter/material.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final Color color;
  final String date;
  final String userId;  // Added required field
  final bool isPinned;  // Properly defined
  final List<String> labels;  // Properly defined

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.color,
    required this.date,
    required this.userId,
    this.isPinned = false,
    this.labels = const [],
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'color': color.value,
      'date': date,
      'userId': userId,
      'isPinned': isPinned,
      'labels': labels,
    };
  }

  // Create from Firestore document
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] ?? '',  // Null checks added
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      color: Color(map['color'] as int? ?? Colors.blue.value),  // Handle null color
      date: map['date'] ?? '',
      userId: map['userId'] ?? '',  // Added userId
      isPinned: map['isPinned'] as bool? ?? false,
      labels: List<String>.from(map['labels'] ?? []),  // Proper list conversion
    );
  }

  // Helper method for updates
  Note copyWith({
    String? id,
    String? title,
    String? content,
    Color? color,
    String? date,
    String? userId,
    bool? isPinned,
    List<String>? labels,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      isPinned: isPinned ?? this.isPinned,
      labels: labels ?? this.labels,
    );
  }
}
