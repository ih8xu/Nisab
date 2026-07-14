import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
  });

  final String message;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          isUser ? Alignment.centerRight : Alignment.centerLeft,

      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),

        constraints: const BoxConstraints(
          maxWidth: 290,
        ),

        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFFF38A71)
              : const Color(0xFF0B3D5C),

          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(
              isUser ? 20 : 6,
            ),
            bottomRight: Radius.circular(
              isUser ? 6 : 20,
            ),
          ),
        ),

        child: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}
