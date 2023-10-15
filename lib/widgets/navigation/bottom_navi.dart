import 'package:flutter/material.dart';
import 'package:moyousky/animation/fade_route.dart';
import 'package:moyousky/views/timeline.dart';

class BskyBottomNavigationBar extends StatelessWidget {
  final Function(int) onTap;

  const BskyBottomNavigationBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Colors.black54, // The named parameter 'selectedItemColor' isn't defined. (Documentation)  Try correcting the name to an existing named parameter's name, or defining a named parameter with the name 'selectedItemColor'.
      unselectedItemColor: Colors.black54,
      selectedFontSize: 10.5,
      unselectedFontSize: 10.5,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home_filled,
            color: Colors.black54,
          ),
          label: "Home",
          backgroundColor: Colors.white,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_rounded, color: Colors.black54),
          label: "Search",
          backgroundColor: Colors.white,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications, color: Colors.black54),
          label: "Notification",
          backgroundColor: Colors.white,
        ),
      ],
      onTap: onTap,
    );
  }
}
