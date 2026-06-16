import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/player_settings.dart';

void main() {
  group('PlayerSettingsStore', () {
    test(
      'migrates legacy autoplay_next when play_end_behavior is missing',
      () async {
        SharedPreferences.setMockInitialValues({
          PlayerSettingsStore.autoplayNextKey: true,
        });
        final prefs = await SharedPreferences.getInstance();
        final store = PlayerSettingsStore(prefs);

        final settings = store.load();

        expect(settings.playEndBehaviorName, 'next');
      },
    );

    test(
      'prefers explicit play_end_behavior over legacy autoplay_next',
      () async {
        SharedPreferences.setMockInitialValues({
          PlayerSettingsStore.autoplayNextKey: false,
          PlayerSettingsStore.playEndBehaviorKey: 'loop',
        });
        final prefs = await SharedPreferences.getInstance();
        final store = PlayerSettingsStore(prefs);

        final settings = store.load();

        expect(settings.playEndBehaviorName, 'loop');
      },
    );

    test('loads and saves actual scene video miniplayer preference', () async {
      SharedPreferences.setMockInitialValues({
        PlayerSettingsStore.useActualSceneVideoInMiniPlayerKey: true,
      });
      final prefs = await SharedPreferences.getInstance();
      final store = PlayerSettingsStore(prefs);

      expect(store.load().useActualSceneVideoInMiniPlayer, isTrue);

      await store.saveUseActualSceneVideoInMiniPlayer(false);

      expect(
        prefs.getBool(PlayerSettingsStore.useActualSceneVideoInMiniPlayerKey),
        isFalse,
      );
      expect(store.load().useActualSceneVideoInMiniPlayer, isFalse);
    });

    test(
      'defaults actual scene video miniplayer preference to enabled',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final store = PlayerSettingsStore(prefs);

        expect(store.load().useActualSceneVideoInMiniPlayer, isTrue);
      },
    );
  });
}
