import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/player_settings.dart';

void main() {
  group('PlayerSettingsStore', () {
    test(
      'mpv defaults and corrupt preferences preserve platform defaults',
      () async {
        for (final value in <Object?>[null, 'unsupported', 42]) {
          SharedPreferences.setMockInitialValues({
            if (value != null) ...{
              PlayerSettingsStore.mpvVoKey: value,
              PlayerSettingsStore.mpvHwdecKey: value,
            },
          });
          final store = PlayerSettingsStore(
            await SharedPreferences.getInstance(),
          );
          expect(store.load().mpvVo, 'default');
          expect(store.load().mpvHwdec, 'default');
          for (final platform in TargetPlatform.values) {
            final config = store.loadVideoConfiguration(platform: platform);
            expect(config.vo, isNull);
            expect(config.hwdec, isNull);
            expect(config.enableHardwareAcceleration, isTrue);
          }
        }
      },
    );

    test(
      'every supported mpv choice reaches the next controller configuration',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final store = PlayerSettingsStore(prefs);
        for (final platform in TargetPlatform.values) {
          for (final vo in PlayerSettingsStore.supportedMpvVoValues(platform)) {
            for (final hwdec in PlayerSettingsStore.supportedMpvHwdecValues(
              platform,
            )) {
              if (vo == 'mediacodec_embed' && hwdec != 'mediacodec') continue;
              await store.saveMpvConfiguration(vo: vo, hwdec: hwdec);
              expect(store.load().mpvVo, vo);
              expect(store.load().mpvHwdec, hwdec);
              final config = store.loadVideoConfiguration(platform: platform);
              expect(config.vo, vo == 'default' ? isNull : vo);
              expect(config.hwdec, hwdec == 'default' ? isNull : hwdec);
              // Software decoding must not also disable GPU output rendering.
              expect(config.enableHardwareAcceleration, isTrue);
            }
          }
        }
        await store.saveMpvConfiguration(vo: 'default', hwdec: 'default');
        expect(store.loadVideoConfiguration().vo, isNull);
        expect(store.loadVideoConfiguration().hwdec, isNull);
      },
    );

    test(
      'imported mpv choices are guarded by platform and decoder compatibility',
      () async {
        SharedPreferences.setMockInitialValues({
          PlayerSettingsStore.mpvVoKey: 'mediacodec_embed',
          PlayerSettingsStore.mpvHwdecKey: 'no',
        });
        final prefs = await SharedPreferences.getInstance();
        final store = PlayerSettingsStore(prefs);
        final software = store.loadVideoConfiguration(
          platform: TargetPlatform.android,
        );
        expect(software.vo, isNull);
        expect(software.hwdec, 'no');

        await store.saveMpvConfiguration(
          vo: 'mediacodec_embed',
          hwdec: 'mediacodec',
        );
        for (final platform in TargetPlatform.values.where(
          (p) => p != TargetPlatform.android,
        )) {
          final config = store.loadVideoConfiguration(platform: platform);
          expect(config.vo, isNull);
          expect(config.hwdec, isNull);
        }
        final web = store.loadVideoConfiguration(
          platform: TargetPlatform.android,
          isWeb: true,
        );
        expect(web.vo, isNull);
        expect(web.hwdec, isNull);

        await store.saveMpvConfiguration(vo: 'libmpv', hwdec: 'auto-copy');
        final android = store.loadVideoConfiguration(
          platform: TargetPlatform.android,
        );
        expect(android.vo, isNull);
        expect(android.hwdec, 'auto-copy');
      },
    );

    test(
      'invalid mpv selections do not overwrite persisted preferences',
      () async {
        SharedPreferences.setMockInitialValues({});
        final store = PlayerSettingsStore(
          await SharedPreferences.getInstance(),
        );
        await store.saveMpvConfiguration(vo: 'gpu', hwdec: 'no');
        for (final (vo, hwdec) in [
          ('gpu-next', 'no'),
          ('gpu', 'invalid'),
          ('mediacodec_embed', 'no'),
          ('mediacodec_embed', 'default'),
        ]) {
          await expectLater(
            store.saveMpvConfiguration(vo: vo, hwdec: hwdec),
            throwsArgumentError,
          );
          expect(store.load().mpvVo, 'gpu');
          expect(store.load().mpvHwdec, 'no');
        }
      },
    );
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

    test('defaults seek interaction to drag', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      expect(PlayerSettingsStore(prefs).load().useDoubleTapSeek, isFalse);
    });
  });
}
