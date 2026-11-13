import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart' as mk;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:stash_app_flutter/features/images/presentation/widgets/image_clip_player.dart';
import 'package:stash_app_flutter/core/utils/app_log_store.dart';

import '../../../../helpers/image_clip_test_helpers.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  setUp(() {
    AppLogStore.instance.isEnabled = true;
    AppLogStore.instance.clear();
  });
  tearDown(() {
    AppLogStore.instance.isEnabled = false;
    AppLogStore.instance.clear();
  });

  Future<void> mount(
    WidgetTester tester,
    FakeClipPlayer player, {
    VoidCallback? onTap,
  }) async {
    await pumpTestWidget(
      tester,
      child: Scaffold(
        body: ImageClipPlayer(url: 'http://localhost/clip', onTap: onTap),
      ),
      overrides: [
        imageClipSessionFactoryProvider.overrideWithValue(
          () => fakeClipSession(player),
        ),
      ],
    );
    await tester.pumpAndSettle();
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    await tester.pumpAndSettle();
  }

  testWidgets(
    'publishes video before open finishes and disposes pending startup',
    (tester) async {
      final player = FakeClipPlayer()..opening = Completer<void>();
      await pumpTestWidget(
        tester,
        child: const Scaffold(
          body: ImageClipPlayer(url: 'http://localhost/clip'),
        ),
        overrides: [
          imageClipSessionFactoryProvider.overrideWithValue(
            () => fakeClipSession(player),
          ),
        ],
      );
      await tester.pump();
      expect(find.byType(Video), findsOneWidget);
      expect(player.opened, isA<mk.Media>());
      expect(player.playCalls, 0);
      await unmount(tester);
      expect(
        player.disposeCalls,
        1,
        reason: AppLogStore.instance.entries.map((e) => e.message).join('\n'),
      );
      player.opening!.complete();
      await tester.pump();
      expect(player.playCalls, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'recoverable decoder errors do not stop playback or replace the surface',
    (tester) async {
      final player = FakeClipPlayer();
      await mount(tester, player);
      expect(player.playlistMode, mk.PlaylistMode.single);
      final surface = tester.state(find.byType(Video));
      player.events.errors.add('recoverable decoder error');
      await tester.pump();
      expect(tester.state(find.byType(Video)), same(surface));
      expect(player.pauseCalls, 0);
      expect(find.byIcon(Icons.refresh), findsNothing);
      await tester.tap(find.byKey(const Key('image_clip_play_pause')));
      await tester.pump();
      expect(player.playing, isFalse);
      await unmount(tester);
    },
  );

  testWidgets(
    'scrubbing commits one seek and retains target until it completes',
    (tester) async {
      final player = FakeClipPlayer()..seeking = Completer<void>();
      var videoTaps = 0;
      await mount(tester, player, onTap: () => videoTaps++);
      final slider = find.byType(Slider);
      final rect = tester.getRect(slider);
      final gesture = await tester.startGesture(
        Offset(rect.left + 70, rect.center.dy),
      );
      await gesture.moveTo(Offset(rect.right - 70, rect.center.dy));
      await tester.pump();
      expect(player.seeks, isEmpty);
      final preview = tester.widget<Slider>(slider).value;
      await gesture.up();
      await tester.pump();
      expect(player.seeks, hasLength(1));
      expect(player.seeks.single.inMilliseconds, closeTo(preview, 1));
      player.events.positions.add(const Duration(seconds: 21));
      await tester.pump();
      expect(tester.widget<Slider>(slider).value, preview);
      expect(videoTaps, 0);
      player.seeking!.complete();
      await tester.pumpAndSettle();
      expect(
        tester.widget<Slider>(slider).value,
        closeTo(player.position.inMilliseconds, 1),
      );
      await unmount(tester);
    },
  );

  testWidgets('seek preview survives acknowledgement until position arrives', (
    tester,
  ) async {
    final player = FakeClipPlayer()..updatePositionOnSeek = false;
    await mount(tester, player);
    final slider = find.byType(Slider);
    final rect = tester.getRect(slider);
    await tester.dragFrom(
      Offset(rect.left + 70, rect.center.dy),
      Offset(rect.width - 140, 0),
    );
    await tester.pump();
    final target = player.seeks.single;
    expect(
      tester.widget<Slider>(slider).value,
      closeTo(target.inMilliseconds, 1),
    );
    player.events.positions.add(const Duration(seconds: 21));
    await tester.pump();
    expect(
      tester.widget<Slider>(slider).value,
      closeTo(target.inMilliseconds, 1),
    );
    player.position = target;
    player.events.positions.add(target);
    await tester.pumpAndSettle();
    expect(
      tester.widget<Slider>(slider).value,
      closeTo(target.inMilliseconds, 1),
    );
    await unmount(tester);
  });

  testWidgets(
    'background pauses once and only resumes previously playing media',
    (tester) async {
      final player = FakeClipPlayer();
      await mount(tester, player);
      player.pausing = Completer<void>();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(player.pauseCalls, 1);
      player.pausing!.complete();
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(player.playCalls, 2);
      await tester.tap(find.byKey(const Key('image_clip_play_pause')));
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(player.playCalls, 2);
      await unmount(tester);
    },
  );

  testWidgets(
    'failed open retries with a fresh session after disposing the old one',
    (tester) async {
      final first = FakeClipPlayer()..openError = StateError('failed to open');
      final second = FakeClipPlayer();
      var attempt = 0;
      await pumpTestWidget(
        tester,
        child: const Scaffold(
          body: ImageClipPlayer(url: 'http://localhost/clip'),
        ),
        overrides: [
          imageClipSessionFactoryProvider.overrideWithValue(
            () => fakeClipSession(attempt++ == 0 ? first : second),
          ),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(first.disposeCalls, 1);
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(
        first.disposeCalls,
        1,
        reason: AppLogStore.instance.entries.map((e) => e.message).join('\n'),
      );
      expect(second.playCalls, 1);
      expect(find.byType(Slider), findsOneWidget);
      await unmount(tester);
      expect(second.disposeCalls, 1);
    },
  );
}
