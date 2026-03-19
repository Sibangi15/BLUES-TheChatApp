import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final String? imageUrl;
  final bool isCurrentUser;
  final VoidCallback? onDelete;

  const ChatBubble({
    super.key,
    required this.message,
    this.imageUrl,
    required this.isCurrentUser,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: isCurrentUser ? onDelete : null,
      child: Container(
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.indigo : Colors.amber,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: imageUrl?.isNotEmpty == true
            ? Image.network(imageUrl!, width: 200)
            : Text(message, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
