import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/navigation_tabs_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/widgets/settings_page_shell.dart';

class NavigationCustomizationPage extends ConsumerWidget {
  const NavigationCustomizationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = ref.watch(navigationTabsProvider);

    return SettingsPageShell(
      title: 'Customize Navigation',
      child: ReorderableListView(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        onReorder: (oldIndex, newIndex) {
          ref.read(navigationTabsProvider.notifier).reorder(oldIndex, newIndex);
        },
        children: [
          for (final tab in tabs)
            ListTile(
              key: ValueKey(tab.type.id),
              leading: const Icon(Icons.drag_handle),
              title: Text(tab.type.label),
              trailing: Switch.adaptive(
                value: tab.visible,
                onChanged: (value) {
                  ref
                      .read(navigationTabsProvider.notifier)
                      .toggleTab(tab.type, value);
                },
              ),
            ),
        ],
      ),
    );
  }
}
