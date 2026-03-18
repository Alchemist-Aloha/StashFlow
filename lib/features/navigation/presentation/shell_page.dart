import 'package:flutter/material.dart';

class ShellPage extends StatelessWidget {
  final Widget child;
  const ShellPage({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.explore), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.subscriptions), label: 'Subscriptions'),
          NavigationDestination(icon: Icon(Icons.video_library), label: 'Library'),
        ],
      ),
    );
  }
}
