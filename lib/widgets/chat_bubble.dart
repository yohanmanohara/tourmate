import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isBot;
  final DateTime timestamp;
  final bool showTimestamp;

  const ChatBubble({
    required this.message,
    required this.isBot,
    required this.timestamp,
    this.showTimestamp = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: 
          isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        if (showTimestamp)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              _formatTime(timestamp),
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
            ),
          ),
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isBot 
                ? Theme.of(context).colorScheme.secondaryContainer
                : Theme.of(context).primaryColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isBot ? 0 : 12),
              topRight: Radius.circular(isBot ? 12 : 0),
              bottomLeft: const Radius.circular(12),
              bottomRight: const Radius.circular(12),
            ),
          ),
          child: Text(
            message,
            style: TextStyle(
              color: isBot 
                  ? Theme.of(context).colorScheme.onSecondaryContainer
                  : Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}