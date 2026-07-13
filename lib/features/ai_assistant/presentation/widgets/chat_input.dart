import 'package:flutter/material.dart';

class ChatInput extends StatelessWidget {
  const ChatInput({
    super.key,
    required this.controller,
    required this.onSend,
  });

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            IconButton(
              onPressed: onSend,
              icon: const Icon(
                Icons.send_rounded,
                color: Color(0xFFF38A71),
              ),
            ),

            Expanded(
              child: TextField(
                controller: controller,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration: InputDecoration(
                  hintText: "اكتب سؤالك...",

                  hintStyle: const TextStyle(
                    color: Colors.white54,
                  ),

                  filled: true,

                  fillColor: const Color(0xFF0B3D5C),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),

                onSubmitted: (_) => onSend(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}