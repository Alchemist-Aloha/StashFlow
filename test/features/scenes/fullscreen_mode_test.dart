import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/global_fullscreen_overlay.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  final testScene = Scene(
    id: 's1',
    title: 'Test Scene',
    date: DateTime(2024, 1, 1),
    rating100: 40,
    oCounter: 5,
    organized: true,
    interactive: false,
    resumeTime: null,
    playCount: 10,
    playDuration: 0,
    files: [],
    paths: const ScenePaths(
      screenshot: null,
      preview: null,
      stream: 'http://test.com/stream.mp4',
    ),
    urls: [],
    studioId: 'st1',
    studioName: 'Test Studio',
    studioImagePath: null,
    performerIds: [],
    performerNames: [],
    performerImagePaths: [],
    tagIds: [],
    tagNames: [],
  );

  test('synchronizes maximized Windows before shared desktop fullscreen', () {
    final overlaySource = File(
      'lib/features/scenes/presentation/widgets/global_fullscreen_overlay.dart',
    ).readAsStringSync();
    final imageSource = File(
      'lib/features/images/presentation/pages/image_fullscreen_page.dart',
    ).readAsStringSync();
    final desktopSource = File(
      'lib/core/utils/desktop_fullscreen.dart',
    ).readAsStringSync();
    final windowsSource = File(
      'windows/runner/flutter_window.cpp',
    ).readAsStringSync();

    expect(overlaySource, contains('await DesktopFullscreen.instance.enter()'));
    expect(overlaySource, contains('await DesktopFullscreen.instance.exit()'));
    expect(imageSource, contains('await DesktopFullscreen.instance.enter()'));
    expect(imageSource, contains('DesktopFullscreen.instance.exit()'));
    expect(
      desktopSource,
      contains('defaultTargetPlatform == TargetPlatform.windows'),
    );
    expect(desktopSource, contains('await windowManager.isMaximized()'));
    expect(desktopSource, contains('await windowManager.unmaximize()'));
    expect(desktopSource, contains('void onWindowUnmaximize()'));
    expect(desktopSource, contains("invokeMethod('setTransitionsEnabled'"));
    expect(desktopSource, contains('void onWindowMaximize()'));
    expect(desktopSource, contains('await windowManager.maximize()'));
    expect(windowsSource, contains('DWMWA_TRANSITIONS_FORCEDISABLED'));
    expect(windowsSource, contains('"stash_app_flutter/window"'));
  });

  testWidgets('GlobalFullscreenOverlay visibility toggles with player state', (
    tester,
  ) async {
    final mockRepo = MockGraphQLSceneRepository()..withData([testScene]);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [sceneRepositoryProvider.overrideWithValue(mockRepo)],
      child: const GlobalFullscreenOverlay(),
    );

    // Trigger fullscreen
    final container = tester.element(find.byType(GlobalFullscreenOverlay));
    final containerRef = ProviderScope.containerOf(container);

    // We need an active scene and controller for the overlay to show content
    // but we can at least test the visibility toggle of the SlideTransition.

    containerRef.read(playerStateProvider.notifier).setFullScreen(true);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      find.byKey(const ValueKey('global_fullscreen_overlay_slide')),
      findsOneWidget,
    );

    // Test exit
    containerRef.read(playerStateProvider.notifier).setFullScreen(false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      find.byKey(const ValueKey('global_fullscreen_overlay_slide')),
      findsNothing,
    );
  });
}
