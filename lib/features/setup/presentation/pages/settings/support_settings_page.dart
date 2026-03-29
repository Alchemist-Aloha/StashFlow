import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupportSettingsPage extends ConsumerWidget {
  const SupportSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      body: const Center(child: Text('Support')),
    );
  }
}
