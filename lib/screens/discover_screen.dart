import 'package:flutter/material.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            'Discover',
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
