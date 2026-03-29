import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppearanceSettingsPage extends ConsumerStatefulWidget {
  const AppearanceSettingsPage({super.key});

  @override
  ConsumerState<AppearanceSettingsPage> createState() => _AppearanceSettingsPageState();
}

class _AppearanceSettingsPageState extends ConsumerState<AppearanceSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appearance Settings')),
      body: const Center(child: Text('Appearance Settings')),
    );
  }
}
