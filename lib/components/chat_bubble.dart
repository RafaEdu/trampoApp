import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    //light vc dark mode for correct bubble colors
    //bool isDarkMode = Provider.of<ThemeProvider>(
    //  context,
    //  listen: false,
    //).isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.grey.shade800 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      child: Text(
        message,
        style: TextStyle(color: isCurrentUser ? Colors.white : Colors.black),
      ),
    );
  }
}
