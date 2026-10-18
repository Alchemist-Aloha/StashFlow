import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/player_settings.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/player_mpv_properties_stub.dart'
    as web;

class _RecordingNativePlayer implements NativePlayer {
  final properties = <String, String>{};
  @override
  Future<void> setProperty(
    String property,
    String value, {
    bool waitForInitialization = true,
  }) async {
    expect(waitForInitialization, isTrue);
    properties[property] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestPlayer implements Player {
  _TestPlayer(this.platform);
  @override
  final NativePlayer platform;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('PlayerSettingsStore', () {
    test('control auto-hide delay defaults, validates, and persists', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = PlayerSettingsStore(prefs);
      expect(const PlayerSettings().controlsAutoHideSeconds, 2);
      expect(store.load().controlsAutoHideSeconds, 2);

      await store.saveControlsAutoHideSeconds(1);
      expect(store.load().controlsAutoHideSeconds, 1);
      await store.saveControlsAutoHideSeconds(4);
      expect(store.load().controlsAutoHideSeconds, 4);
      expect(() => store.saveControlsAutoHideSeconds(11), throwsArgumentError);
      expect(store.load().controlsAutoHideSeconds, 4);
      await prefs.setInt(PlayerSettingsStore.controlsAutoHideSecondsKey, 99);
      expect(store.load().controlsAutoHideSeconds, 2);
      await prefs.setString(
        PlayerSettingsStore.controlsAutoHideSecondsKey,
        'invalid',
      );
      expect(store.load().controlsAutoHideSeconds, 2);
    });

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
              expect(
                config.vo,
                vo == 'default'
                    ? isNull
                    : vo == 'libmpv-software'
                    ? 'libmpv'
                    : vo,
              );
              expect(config.hwdec, hwdec == 'default' ? isNull : hwdec);
              // Software decoding alone must not disable GPU rendering.
              expect(
                config.enableHardwareAcceleration,
                vo != 'libmpv-software',
              );
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
      'Linux-only modes preserve embedding and are filtered elsewhere',
      () async {
        SharedPreferences.setMockInitialValues({});
        final store = PlayerSettingsStore(
          await SharedPreferences.getInstance(),
        );
        for (final decoder in [
          'vaapi',
          'vaapi-copy',
          'nvdec',
          'nvdec-copy',
          'vdpau-copy',
        ]) {
          await store.saveMpvConfiguration(
            vo: 'libmpv-software',
            hwdec: decoder,
          );
          final linux = store.loadVideoConfiguration(
            platform: TargetPlatform.linux,
          );
          expect(linux.vo, 'libmpv');
          expect(linux.enableHardwareAcceleration, isFalse);
          expect(linux.hwdec, decoder);
          for (final platform in TargetPlatform.values.where(
            (p) => p != TargetPlatform.linux,
          )) {
            final other = store.loadVideoConfiguration(platform: platform);
            expect(other.vo, isNull);
            expect(other.hwdec, isNull);
            expect(other.enableHardwareAcceleration, isTrue);
          }
        }
        await store.saveMpvConf(
          'interpolation=yes\nscale=lanczos\naudio-delay=0.1',
        );
        expect(store.loadMpvProperties(platform: TargetPlatform.linux), {
          'audio-delay': '0.1',
        });
        for (final vo in ['gpu-next', 'gpu', 'mediacodec_embed']) {
          expect(
            PlayerSettingsStore.supportedMpvVoValues(TargetPlatform.linux),
            isNot(contains(vo)),
          );
        }
        final web = store.loadVideoConfiguration(
          platform: TargetPlatform.linux,
          isWeb: true,
        );
        expect(web.vo, isNull);
        expect(web.hwdec, isNull);
        expect(web.enableHardwareAcceleration, isTrue);
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
          ('invalid', 'no'),
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
      'rendering choices persist and custom options take precedence',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final store = PlayerSettingsStore(prefs);
        expect(store.loadMpvProperties(), isEmpty);
        for (final entry in PlayerSettingsStore.mpvChoices.entries) {
          for (final value in entry.value) {
            await store.saveMpvOption(entry.key, value);
            expect(store.loadMpvOption(entry.key), value);
          }
          await store.saveMpvOption(entry.key, 'default');
        }
        await store.saveMpvOption('interpolation', 'yes');
        expect(store.loadMpvProperties(), {
          'interpolation': 'yes',
          'video-sync': 'display-resample',
        });
        await store.saveMpvOption('tscale', 'linear');
        await store.saveMpvConf(
          '# motion\r\ntscale="oversample"\nvideo-sync=audio\n',
        );
        expect(store.loadMpvProperties(), {
          'interpolation': 'yes',
          'tscale': 'oversample',
          'video-sync': 'audio',
        });
        expect(store.loadMpvProperties(isWeb: true), isEmpty);
        await store.saveMpvConf('');
        expect(store.loadMpvProperties()['tscale'], 'linear');
        await prefs.setInt(PlayerSettingsStore.mpvOptionKey('tscale'), 42);
        expect(store.loadMpvOption('tscale'), 'default');
        await expectLater(
          store.saveMpvOption('tscale', 'invalid'),
          throwsArgumentError,
        );
        await store.saveMpvConfiguration(
          vo: 'mediacodec_embed',
          hwdec: 'mediacodec',
        );
        await store.saveMpvConf(
          'audio-delay=0.1\ncache-secs=20\nscale=lanczos',
        );
        expect(store.loadMpvProperties(platform: TargetPlatform.android), {
          'audio-delay': '0.1',
          'cache-secs': '20',
        });
      },
    );

    test(
      'custom config parses flat options and rejects unsafe or invalid input',
      () async {
        expect(
          PlayerSettingsStore.parseMpvConf(
            " # comment\n\ndeband\ntscale='linear'\ntscale=oversample\n",
          ),
          {'deband': 'yes', 'tscale': 'oversample'},
        );
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final store = PlayerSettingsStore(prefs);
        await store.saveMpvConf('deband=yes');
        for (final invalid in [
          '[profile]\nscale=lanczos',
          'include=file.conf',
          'script=file.lua',
          'vo=gpu-next',
          'hwdec=no',
          'wid=1',
          'http-header-fields=secret',
          'unknown=yes',
          'scale=',
          'scale=\u0000',
          'x' * 16385,
        ]) {
          expect(PlayerSettingsStore.isValidMpvConf(invalid), isFalse);
          await expectLater(store.saveMpvConf(invalid), throwsFormatException);
          expect(store.mpvConf, 'deband=yes');
        }
        await prefs.setString(PlayerSettingsStore.mpvConfKey, 'include=bad');
        expect(store.mpvConf, isEmpty);
        await prefs.setInt(PlayerSettingsStore.mpvConfKey, 42);
        expect(store.mpvConf, isEmpty);
      },
    );

    test('web ignores runtime mpv options', () async {
      final native = _RecordingNativePlayer();
      await web.applyPlayerMpvProperties(native, {'deband': 'yes'});
      expect(native.properties, isEmpty);
    });

    test(
      'runtime options are awaited and applied to the native player',
      () async {
        SharedPreferences.setMockInitialValues({});
        final store = PlayerSettingsStore(
          await SharedPreferences.getInstance(),
        );
        final native = _RecordingNativePlayer();
        final player = _TestPlayer(native);
        await store.applyMpvProperties(player);
        expect(native.properties, isEmpty);
        await store.saveMpvOption('interpolation', 'yes');
        await store.saveMpvConf('tscale=linear');
        await store.applyMpvProperties(player);
        expect(native.properties, {
          'interpolation': 'yes',
          'tscale': 'linear',
          'video-sync': 'display-resample',
        });
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
