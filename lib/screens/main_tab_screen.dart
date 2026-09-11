import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'history_screen.dart';
import 'discover_screen.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    HistoryScreen(),
    DiscoverScreen(),
    ChatScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF140D20) : const Color(0xFFF9F9F9),
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF21182E) : Colors.white,
            borderRadius: BorderRadius.circular(40),
            border: isDark
                ? Border.all(
                    color: const Color(0xFF3A2C4D),
                    width: 1,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.28 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildTab(0, Icons.home_rounded, 'Home'),
              _buildTab(1, Icons.history_rounded, 'History'),
              _buildTab(2, Icons.explore_outlined, 'Discover'),
              _buildTab(3, Icons.chat_bubble_outline_rounded, 'Chat'),
              _buildTab(4, Icons.settings_outlined, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int index, IconData icon, String label) {
    final selected = selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedColor =
        isDark ? const Color(0xFF8B5CF6) : const Color(0xFFFF6338);

    final unselectedColor =
        isDark ? const Color(0xFFD8D0E2) : Colors.black;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => setState(() => selectedIndex = index),
        child: SizedBox(
          height: 70,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 27,
                color: selected ? selectedColor : unselectedColor,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? selectedColor : unselectedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
