import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomSection extends StatelessWidget {
  final int selectedIndex;

  const BottomSection({super.key, required this.selectedIndex});

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard/home');
        break;
      case 1:
        context.go('/dashboard/record');
        break;
      case 2:
        context.go('/dashboard/contact');
        break;
      case 3:
        context.go('/dashboard/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xff8654B0), // New purple background color
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => _onItemTapped(context, index),
        backgroundColor: const Color(0xff8654B0), // Matching background color
        selectedItemColor: Colors.white, // Changed to white for better contrast
        unselectedItemColor: Colors.white.withOpacity(0.7), // Semi-transparent white
        selectedFontSize: 12,
        unselectedFontSize: 12,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded), // Home icon
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded), // Calendar icon for Record
            label: 'Record',
          ),
         BottomNavigationBarItem(
             icon: Icon(Icons.support_agent), // Better icon for Support Center
          label: 'Support Center',
),

          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}