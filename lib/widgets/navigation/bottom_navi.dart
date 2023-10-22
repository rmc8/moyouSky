import 'package:flutter/material.dart';

class BskyBottomNavigationBar extends StatelessWidget {
  final Function(int) onTap;

  const BskyBottomNavigationBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black54,
      unselectedItemColor: Colors.black54,
      selectedFontSize: 10.5,
      unselectedFontSize: 10.5,
      items: _items(),
      onTap: onTap,
    );
  }

  List<BottomNavigationBarItem> _items() {
    return <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(
          Icons.home_filled,
          color: Colors.black54,
        ),
        label: "Home",
        backgroundColor: Colors.white,
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.search_rounded, color: Colors.black54),
        label: "Search",
        backgroundColor: Colors.white,
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.notifications, color: Colors.black54),
        label: "Notification",
        backgroundColor: Colors.white,
      ),
    ];
  }
}
