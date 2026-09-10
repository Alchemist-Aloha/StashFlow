import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/player_settings.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/pages/settings/playback_settings_page.dart';
import 'package:stash_app_flutter/features/setup/presentation/widgets/settings_page_shell.dart';

import '../../../../../helpers/test_helpers.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'video_gravity_orientation': true});
    prefs = await SharedPreferences.getInstance();
  });

  testWidgets(
    'mpv selectors persist, pair direct output, and restore defaults',
    (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await pumpTestWidget(
        tester,
        prefs: prefs,
        child: const PlaybackSettingsPage(),
      );
      await tester.pumpAndSettle();
      final store = PlayerSettingsStore(prefs);
      expect(store.loadVideoConfiguration().vo, isNull);
      expect(store.loadVideoConfiguration().hwdec, isNull);

      Future<void> select(String title, String option) async {
        await tester.ensureVisible(find.text(title));
        await tester.pumpAndSettle();
        await tester.tap(find.text(title));
        await tester.pumpAndSettle();
        final choice = find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text(option),
        );
        await tester.ensureVisible(choice);
        await tester.pumpAndSettle();
        await tester.tap(choice);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      await select(
        'Video output (vo)',
        'Direct Android output (mediacodec_embed)',
      );
      expect(prefs.getString(PlayerSettingsStore.mpvVoKey), 'mediacodec_embed');
      expect(prefs.getString(PlayerSettingsStore.mpvHwdecKey), 'mediacodec');
      expect(store.loadVideoConfiguration().vo, 'mediacodec_embed');
      expect(store.loadVideoConfiguration().hwdec, 'mediacodec');

      await select('Hardware decoding (hwdec)', 'Software decoding (no)');
      expect(prefs.getString(PlayerSettingsStore.mpvVoKey), 'default');
      expect(prefs.getString(PlayerSettingsStore.mpvHwdecKey), 'no');
      expect(store.loadVideoConfiguration().vo, isNull);
      expect(store.loadVideoConfiguration().hwdec, 'no');
      await select('Video output (vo)', 'GPU output (gpu)');
      expect(store.loadVideoConfiguration().vo, 'gpu');
      expect(store.loadVideoConfiguration().hwdec, 'no');

      // Reopening the settings page must show the persisted pair.
      await tester.pumpWidget(const SizedBox());
      await pumpTestWidget(
        tester,
        prefs: prefs,
        child: const PlaybackSettingsPage(),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Hardware decoding (hwdec)'));
      await tester.pumpAndSettle();
      expect(find.text('Software decoding (no)'), findsOneWidget);
      expect(find.textContaining('GPU output (gpu)'), findsOneWidget);

      await select('Video output (vo)', 'Platform default');
      await select('Hardware decoding (hwdec)', 'Platform default');
      expect(store.loadVideoConfiguration().vo, isNull);
      expect(store.loadVideoConfiguration().hwdec, isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  testWidgets('desktop mpv selectors exclude Android-only choices', (
    tester,
  ) async {
    await prefs.setString(PlayerSettingsStore.mpvVoKey, 'mediacodec_embed');
    await prefs.setString(PlayerSettingsStore.mpvHwdecKey, 'mediacodec');
    await pumpTestWidget(
      tester,
      prefs: prefs,
      child: const PlaybackSettingsPage(),
    );
    await tester.pumpAndSettle();
    final title = find.text('Video output (vo)');
    await tester.ensureVisible(title);
    await tester.pumpAndSettle();
    await tester.tap(title);
    await tester.pumpAndSettle();
    expect(find.text('Embedded output (libmpv)'), findsOneWidget);
    expect(find.text('GPU output (gpu)'), findsNothing);
    expect(find.text('Direct Android output (mediacodec_embed)'), findsNothing);
    await tester.tap(find.text('Embedded output (libmpv)'));
    await tester.pumpAndSettle();
    expect(PlayerSettingsStore(prefs).loadVideoConfiguration().vo, 'libmpv');

    await tester.ensureVisible(find.text('Hardware decoding (hwdec)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hardware decoding (hwdec)'));
    await tester.pumpAndSettle();
    expect(find.text('Software decoding (no)'), findsOneWidget);
    expect(find.text('Android hardware decoder (mediacodec)'), findsNothing);
    expect(
      find.text('Android hardware decoder, copy-back (mediacodec-copy)'),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('PlaybackSettingsPage renders gravity orientation toggle', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      child: const PlaybackSettingsPage(),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPanelCard), findsWidgets);
    expect(find.text('Gravity-controlled orientation'), findsOneWidget);
    expect(
      find.textContaining('Allow rotating between matching orientations'),
      findsOneWidget,
    );

    // Find the switch that is part of the gravity orientation ListTile
    // We can use descendant search
    final gravitySwitch = find.descendant(
      of: find.ancestor(
        of: find.text('Gravity-controlled orientation'),
        matching: find.byType(SwitchListTile),
      ),
      matching: find.byType(Switch),
    );

    expect(tester.widget<Switch>(gravitySwitch).value, isTrue);

    await tester.tap(gravitySwitch);
    await tester.pumpAndSettle();

    expect(tester.widget<Switch>(gravitySwitch).value, isFalse);
    expect(prefs.getBool('video_gravity_orientation'), isFalse);
  });

  testWidgets(
    'existing playback selectors persist choices from bottom sheets',
    (tester) async {
      await pumpTestWidget(
        tester,
        prefs: prefs,
        child: const PlaybackSettingsPage(),
      );
      await tester.pumpAndSettle();
      for (final (title, option, key, value) in [
        (
          'Play End Behavior',
          'Loop current scene',
          'video_play_end_behavior',
          'loop',
        ),
        (
          'Default Subtitle Language',
          'Japanese',
          'default_subtitle_language',
          'ja',
        ),
        (
          'Subtitle Text Alignment',
          'Right',
          'subtitle_text_alignment',
          'right',
        ),
      ]) {
        await tester.ensureVisible(find.text(title));
        await tester.pumpAndSettle();
        await tester.tap(find.text(title));
        await tester.pumpAndSettle();
        final choice = find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text(option),
        );
        await tester.ensureVisible(choice);
        await tester.pumpAndSettle();
        await tester.tap(choice);
        await tester.pumpAndSettle();
        expect(prefs.getString(key), value);
      }
      final state = ProviderScope.containerOf(
        tester.element(find.byType(PlaybackSettingsPage)),
      ).read(playerStateProvider);
      expect(state.playEndBehavior, VideoEndBehavior.loop);
      expect(state.defaultSubtitleLanguage, 'ja');
      expect(state.subtitleTextAlignment, 'right');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('PlaybackSettingsPage omits the obsolete sceneStreams toggle', (
    tester,
  ) async {
    await pumpTestWidget(
      tester,
      prefs: prefs,
      child: const PlaybackSettingsPage(),
    );
    await tester.pumpAndSettle();

    expect(find.text('Prefer sceneStreams first'), findsNothing);
  });

  testWidgets('PlaybackSettingsPage omits the direct-play setting', (
    tester,
  ) async {
    await pumpTestWidget(
      tester,
      prefs: prefs,
      child: const PlaybackSettingsPage(),
    );
    await tester.pumpAndSettle();

    expect(find.text('Direct-play on scene navigation'), findsNothing);
  });

  testWidgets(
    'PlaybackSettingsPage defaults preferred fullscreen off and persists it',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await pumpTestWidget(
        tester,
        prefs: prefs,
        child: const PlaybackSettingsPage(),
      );
      await tester.pumpAndSettle();

      final title = find.text('Open scenes in fullscreen');
      expect(title, findsOneWidget);
      await tester.ensureVisible(title);
      final fullscreenSwitch = find.descendant(
        of: find.ancestor(of: title, matching: find.byType(SwitchListTile)),
        matching: find.byType(Switch),
      );

      expect(tester.widget<Switch>(fullscreenSwitch).value, isFalse);

      await tester.tap(fullscreenSwitch);
      await tester.pumpAndSettle();

      expect(tester.widget<Switch>(fullscreenSwitch).value, isTrue);
      expect(prefs.getBool('video_enter_fullscreen_on_navigation'), isTrue);
    },
  );

  testWidgets(
    'PlaybackSettingsPage renders feed random start position toggle and updates prefs',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await pumpTestWidget(
        tester,
        prefs: prefs,
        child: const PlaybackSettingsPage(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Start Feed from random position'), findsOneWidget);
      expect(
        find.textContaining('start from a random position between 0% and 90%'),
        findsOneWidget,
      );

      final feedRandomSwitch = find.descendant(
        of: find.ancestor(
          of: find.text('Start Feed from random position'),
          matching: find.byType(SwitchListTile),
        ),
        matching: find.byType(Switch),
      );

      expect(tester.widget<Switch>(feedRandomSwitch).value, isFalse);

      await tester.tap(feedRandomSwitch);
      await tester.pumpAndSettle();

      expect(tester.widget<Switch>(feedRandomSwitch).value, isTrue);
      expect(prefs.getBool('feed_start_random'), isTrue);
    },
  );

  testWidgets('resume-position changes update the live player state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      child: const PlaybackSettingsPage(),
    );
    await tester.pumpAndSettle();

    final title = find.text('Resume from last playing position');
    await tester.ensureVisible(title);
    final resumeSwitch = find.descendant(
      of: find.ancestor(of: title, matching: find.byType(SwitchListTile)),
      matching: find.byType(Switch),
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(PlaybackSettingsPage)),
      listen: false,
    );

    expect(container.read(playerStateProvider).resumePlayPosition, isTrue);
    await tester.tap(resumeSwitch);
    await tester.pumpAndSettle();

    expect(prefs.getBool('video_resume_play_position'), isFalse);
    expect(container.read(playerStateProvider).resumePlayPosition, isFalse);
  });
}
