import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavWidget extends StatelessWidget {
  const BottomNavWidget({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: BottomNavigationBar(
          onTap: (index) => _onTap(context, index),
          backgroundColor: const Color(0xffe0b9f6),
          currentIndex: navigationShell.currentIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Login'),
          ],
        ),
      ),
    );
  }
}
