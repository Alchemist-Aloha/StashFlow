import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InterfaceSettingsPage extends ConsumerStatefulWidget {
  const InterfaceSettingsPage({super.key});

  @override
  ConsumerState<InterfaceSettingsPage> createState() => _InterfaceSettingsPageState();
}

class _InterfaceSettingsPageState extends ConsumerState<InterfaceSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interface Settings')),
      body: const Center(child: Text('Interface Settings')),
    );
  }
}
