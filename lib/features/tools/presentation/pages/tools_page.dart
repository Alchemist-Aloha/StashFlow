import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    void fallbackBack() => context.go('/scenes');

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          fallbackBack();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: canPop
              ? null
              : IconButton(
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  icon: const BackButtonIcon(),
                  onPressed: fallbackBack,
                ),
          title: const Text('Tools'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.difference),
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => context.push('/tools/scene-deduplication'),
                    child: const Text('Scene Deduplication'),
                  ),
                ),
                subtitle: const Text('Find and manage duplicate scenes'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/tools/scene-deduplication'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.sell_outlined),
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => context.push('/tools/scene-tagger'),
                    child: const Text('Scene Tagger'),
                  ),
                ),
                subtitle: const Text(
                  'Scrape current scene pages with Stash-box',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/tools/scene-tagger'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
