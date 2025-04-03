import 'package:flutter/material.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final Color color;
  final String date;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.color,
    required this.date,
  });

  // Add these if you need Firestore integration
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'color': color.value,
      'date': date,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      color: Color(map['color']),
      date: map['date'],
    );
  }

  get isPinned => null;

  get labels => null;
}