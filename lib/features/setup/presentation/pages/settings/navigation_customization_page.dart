import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/navigation_tabs_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/widgets/settings_page_shell.dart';

class NavigationCustomizationPage extends ConsumerWidget {
  const NavigationCustomizationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = ref.watch(navigationTabsProvider);

    return SettingsPageShell(
      title: context.l10n.settings_interface_customize_tabs,
      child: SettingsPageBody(
        scrollable: false,
        padding: EdgeInsets.all(context.dimensions.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsSectionCard(
              wrapInPanel: false,
              title: context.l10n.settings_interface_customize_tabs,
              subtitle: context.l10n.settings_interface_customize_tabs_subtitle,
              child: const SizedBox.shrink(),
            ),
            Expanded(
              child: SettingsPanelCard(
                child: ReorderableListView(
                  buildDefaultDragHandles: false,
                  onReorderItem: (oldIndex, newIndex) {
                    unawaited(
                      ref
                          .read(navigationTabsProvider.notifier)
                          .reorder(oldIndex, newIndex),
                    );
                  },
                  children: [
                    for (var index = 0; index < tabs.length; index++)
                      ListTile(
                        key: ValueKey(tabs[index].type.id),
                        leading: ReorderableDragStartListener(
                          index: index,
                          child: SizedBox(
                            width: context.dimensions.buttonHeight.clamp(
                              48.0,
                              double.infinity,
                            ),
                            height: context.dimensions.buttonHeight.clamp(
                              48.0,
                              double.infinity,
                            ),
                            child: Icon(
                              Icons.drag_handle,
                              size: 24 * context.dimensions.fontSizeFactor,
                            ),
                          ),
                        ),
                        title: Text(tabs[index].type.localizedLabel(context)),
                        trailing: Switch.adaptive(
                          value: tabs[index].visible,
                          onChanged: (value) {
                            unawaited(
                              ref
                                  .read(navigationTabsProvider.notifier)
                                  .toggleTab(tabs[index].type, value),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
