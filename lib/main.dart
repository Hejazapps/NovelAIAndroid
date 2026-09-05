import 'package:flutter/material.dart';
import 'screens/main_tab_screen.dart';

void main() {
  runApp(const NovelAIApp());
}

class NovelAIApp extends StatelessWidget {
  const NovelAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NovelAI',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
      ),
      home: const MainTabScreen(),
    );
  }
}
