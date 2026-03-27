import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_list_provider.dart';

void main() {
  group('PerformerFilterNotifier', () {
    test(
      'build handles List<String> in shared preferences correctly',
      () async {
        SharedPreferences.setMockInitialValues({
          'performer_filter_gender': ['female', 'male'],
        });
        final prefs = await SharedPreferences.getInstance();

        final container = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );

        final filterState = container.read(performerFilterProvider);
        expect(filterState.genders, ['female', 'male']);
      },
    );

    test(
      'build handles legacy String in shared preferences correctly',
      () async {
        SharedPreferences.setMockInitialValues({
          'performer_filter_gender': 'female',
        });
        final prefs = await SharedPreferences.getInstance();

        final container = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );

        final filterState = container.read(performerFilterProvider);
        expect(filterState.genders, ['female']);
      },
    );

    test(
      'build handles favoritesOnly in shared preferences correctly',
      () async {
        SharedPreferences.setMockInitialValues({
          'performer_filter_favorites_only': true,
        });
        final prefs = await SharedPreferences.getInstance();

        final container = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );

        final filterState = container.read(performerFilterProvider);
        expect(filterState.favoritesOnly, isTrue);
      },
    );

    test('build handles empty shared preferences correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      final filterState = container.read(performerFilterProvider);
      expect(filterState.genders, isEmpty);
      expect(filterState.favoritesOnly, isFalse);
    });
  });
}
