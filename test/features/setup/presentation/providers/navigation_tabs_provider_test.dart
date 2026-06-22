import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/navigation_tabs_provider.dart';

void main() {
  group('NavigationTabsNotifier', () {
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
