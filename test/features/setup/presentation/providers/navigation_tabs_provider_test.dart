import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/navigation_tabs_provider.dart';

void main() {
  group('NavigationTabsNotifier', () {
    test('reordering and visibility survive provider recreation', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      final notifier = container.read(navigationTabsProvider.notifier);

      await notifier.reorder(4, 0);
      await notifier.reorder(1, 5);
      await notifier.toggleTab(NavigationTabType.performers, false);
      await notifier.toggleTab(NavigationTabType.groups, true);
      final expected = container
          .read(navigationTabsProvider)
          .map((tab) => tab.toJson())
          .toList();
      expect(expected.first['id'], 'galleries');
      expect(expected.last['id'], 'scenes');

      final restored = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(restored.dispose);
      expect(
        restored
            .read(navigationTabsProvider)
            .map((tab) => tab.toJson())
            .toList(),
        expected,
      );
    });

    test(
      'restores saved order, appends missing tabs and keeps a destination',
      () async {
        SharedPreferences.setMockInitialValues({
          'navigation_tabs_config': jsonEncode([
            {'id': 'galleries', 'visible': false},
            {'id': 'scenes', 'visible': false},
            {'id': 'performers', 'visible': false},
            {'id': 'studios', 'visible': false},
            {'id': 'tags', 'visible': false},
            {'id': 'galleries', 'visible': false},
          ]),
        });
        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );
        addTearDown(container.dispose);
        final tabs = container.read(navigationTabsProvider);
        expect(tabs.map((tab) => tab.type), [
          NavigationTabType.galleries,
          NavigationTabType.scenes,
          NavigationTabType.performers,
          NavigationTabType.studios,
          NavigationTabType.tags,
          NavigationTabType.groups,
        ]);
        expect(
          tabs.where((tab) => tab.visible).single.type,
          NavigationTabType.galleries,
        );
        await container
            .read(navigationTabsProvider.notifier)
            .toggleTab(NavigationTabType.galleries, false);
        expect(container.read(navigationTabsProvider).first.visible, isTrue);
      },
    );

    test('defaults groups to hidden in a fresh config', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      final tabs = container.read(navigationTabsProvider);

      expect(
        tabs.firstWhere((tab) => tab.type == NavigationTabType.groups).visible,
        isFalse,
      );
    });

    test(
      'appends missing groups tab as hidden when restoring older config',
      () async {
        SharedPreferences.setMockInitialValues({
          'navigation_tabs_config': jsonEncode([
            {'id': 'scenes', 'visible': true},
            {'id': 'performers', 'visible': true},
            {'id': 'studios', 'visible': true},
            {'id': 'tags', 'visible': true},
            {'id': 'galleries', 'visible': true},
          ]),
        });
        final prefs = await SharedPreferences.getInstance();

        final container = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );
        addTearDown(container.dispose);

        final tabs = container.read(navigationTabsProvider);

        expect(tabs.map((tab) => tab.type), contains(NavigationTabType.groups));
        expect(
          tabs
              .firstWhere((tab) => tab.type == NavigationTabType.groups)
              .visible,
          isFalse,
        );
      },
    );
  });
}
