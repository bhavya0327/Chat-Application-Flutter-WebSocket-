import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSentByUser;
  final String avatar;
  final String timestamp;

  ChatBubble({required this.message, required this.isSentByUser, required this.avatar, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: isSentByUser ? Colors.lightBlueAccent.shade100 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: isSentByUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 5),
          Text(
            timestamp,
            style: TextStyle(fontSize: 12, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
