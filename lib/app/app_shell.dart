import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

import "../core/widgets/archival_nav_bar.dart";

/// Bottom-navigation shell: Home, Habits, Rooms, Notes, You.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _labels = ["Home", "Habits", "Rooms", "Notes", "You"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(bottom: false, child: navigationShell),
      bottomNavigationBar: ArchivalNavBar(
        labels: _labels,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
