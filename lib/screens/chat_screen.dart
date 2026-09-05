import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            'Chat',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
