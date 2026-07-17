import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart' as mk;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:stash_app_flutter/core/utils/app_log_store.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/fullscreen_controller.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/player_view_mode.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/global_fullscreen_overlay.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';

import '../../helpers/test_helpers.dart';

Future<void> _pumpUntil(WidgetTester tester, bool Function() condition) async {
  for (var attempt = 0; attempt < 20 && !condition(); attempt++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

class _ExitPlayerStream extends Mock implements mk.PlayerStream {
  _ExitPlayerStream(this.playingEvents);

  final Stream<bool> playingEvents;

  @override
  Stream<bool> get playing => playingEvents;
}

class _ResumeFailingPlayer extends Mock implements mk.Player {
  _ResumeFailingPlayer()
    : _playingController = StreamController<bool>.broadcast() {
    _stream = _ExitPlayerStream(_playingController.stream);
  }

  final StreamController<bool> _playingController;
  late final mk.PlayerStream _stream;
  bool isPlaying = true;
  int playAttempts = 0;

  @override
  mk.PlayerState get state => mk.PlayerState(playing: isPlaying);

  @override
  mk.PlayerStream get stream => _stream;

  @override
  Future<void> play() async {
    playAttempts += 1;
    throw StateError('resume failed');
  }

  void emitPlaying() => _playingController.add(isPlaying);

  Future<void> close() => _playingController.close();
}

class _ExitVideoController extends Mock implements VideoController {
  _ExitVideoController(this.testPlayer);

  final mk.Player testPlayer;

  @override
  mk.Player get player => testPlayer;
}

class _ExitTestPlayerState extends PlayerState {
  _ExitTestPlayerState(this.testPlayer, this.testController);

  final mk.Player testPlayer;
  final VideoController testController;

  @override
  GlobalPlayerState build() {
    return GlobalPlayerState(
      player: testPlayer,
      videoController: testController,
    );
  }
}

void main() {
  const windowsFullscreenChannel = MethodChannel(
    'stash_app_flutter/window_fullscreen',
  );
  late SharedPreferences prefs;
  late Future<Object?> Function(MethodCall call) windowsFullscreenHandler;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    AppLogStore.instance
      ..isEnabled = true
      ..clear();
    windowsFullscreenHandler = (call) async => null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          windowsFullscreenChannel,
          (call) => windowsFullscreenHandler(call),
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async => null,
        );
  });

  tearDown(() {
    AppLogStore.instance
      ..clear()
      ..isEnabled = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowsFullscreenChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
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

  test('uses an app-owned Windows borderless fullscreen transition', () {
    final overlaySource = File(
      'lib/features/scenes/presentation/widgets/global_fullscreen_overlay.dart',
    ).readAsStringSync();
    final imageSource = File(
      'lib/features/images/presentation/pages/image_fullscreen_page.dart',
    ).readAsStringSync();
    final desktopSource = File(
      'lib/core/utils/desktop_fullscreen.dart',
    ).readAsStringSync();
    final runnerSource = File(
      'windows/runner/flutter_window.cpp',
    ).readAsStringSync();
    final controllerFile = File(
      'windows/runner/windows_fullscreen_controller.cpp',
    );
    final cmakeSource = File(
      'windows/runner/CMakeLists.txt',
    ).readAsStringSync();

    expect(overlaySource, contains('await DesktopFullscreen.instance.enter()'));
    expect(overlaySource, contains('await DesktopFullscreen.instance.exit()'));
    expect(imageSource, contains('await DesktopFullscreen.instance.enter()'));
    expect(imageSource, contains('DesktopFullscreen.instance.exit()'));
    expect(desktopSource, contains("invokeMethod<void>('enter')"));
    expect(desktopSource, contains("invokeMethod<void>('exit')"));
    expect(runnerSource, contains('stash_app_flutter/window_fullscreen'));
    expect(controllerFile.existsSync(), isTrue);

    final controllerSource = controllerFile.readAsStringSync();
    expect(controllerSource, contains('GetWindowPlacement'));
    expect(controllerSource, contains('GWL_STYLE'));
    expect(controllerSource, contains('GWL_EXSTYLE'));
    expect(controllerSource, contains('WS_OVERLAPPEDWINDOW'));
    expect(controllerSource, contains('WS_CAPTION'));
    expect(controllerSource, contains('monitor.rcMonitor'));
    expect(controllerSource, contains('SetWindowPlacement'));
    expect(controllerSource, contains('saved_was_maximized_'));
    expect(controllerSource, contains('::IsZoomed(window_)'));
    expect(controllerSource, contains('::ShowWindow(window_, SW_RESTORE)'));
    expect(controllerSource, contains('::ShowWindow(window_, SW_MAXIMIZE)'));
    expect(
      controllerSource,
      contains('Restored GWL_STYLE does not match saved style'),
    );
    expect(
      controllerSource,
      contains('Restored GWL_EXSTYLE does not match saved style'),
    );
    expect(
      controllerSource,
      contains('Restored maximized state does not match saved state'),
    );
    expect(controllerSource, contains('::RedrawWindow(window_'));
    expect(
      controllerSource,
      contains('RDW_FRAME | RDW_INVALIDATE | RDW_UPDATENOW'),
    );
    expect(controllerSource, contains('::DwmFlush()'));
    expect(controllerSource, contains('RedrawWindow failed'));
    expect(
      controllerSource,
      contains('HResultError("DwmFlush", flush_result)'),
    );
    expect(controllerSource, contains('failed with HRESULT'));

    final restoreFrameChange = controllerSource.lastIndexOf(
      '::SetWindowPos(window_, nullptr',
    );
    final nonClientRedraw = controllerSource.indexOf(
      '::RedrawWindow(window_',
      restoreFrameChange,
    );
    final compositorFlush = controllerSource.indexOf(
      '::DwmFlush()',
      nonClientRedraw,
    );
    expect(restoreFrameChange, greaterThanOrEqualTo(0));
    expect(nonClientRedraw, greaterThan(restoreFrameChange));
    expect(compositorFlush, greaterThan(nonClientRedraw));
    expect(controllerSource, isNot(contains('HWND_TOPMOST')));
    expect(cmakeSource, contains('windows_fullscreen_controller.cpp'));
  });

  testWidgets('waits for native exit before hiding fullscreen overlay', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      final exitCompleter = Completer<Object?>();
      var blockExit = false;
      var exitInvoked = false;
      windowsFullscreenHandler = (call) {
        if (call.method == 'exit' && blockExit) {
          exitInvoked = true;
          return exitCompleter.future;
        }
        return Future<Object?>.value();
      };
      final mockRepo = MockGraphQLSceneRepository()..withData([testScene]);

      await pumpTestWidget(
        tester,
        prefs: prefs,
        overrides: [sceneRepositoryProvider.overrideWithValue(mockRepo)],
        child: const GlobalFullscreenOverlay(),
      );

      final container = tester.element(find.byType(GlobalFullscreenOverlay));
      final containerRef = ProviderScope.containerOf(container);
      containerRef.read(playerStateProvider.notifier).setFullScreen(true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      blockExit = true;
      containerRef.read(playerStateProvider.notifier).requestExitFullscreen();
      await tester.pump();

      expect(
        containerRef.read(playerStateProvider).fullscreenPhase,
        FullscreenPhase.exiting,
      );
      expect(containerRef.read(playerStateProvider).isFullScreen, isTrue);
      expect(
        containerRef.read(playerStateProvider).viewMode,
        PlayerViewMode.fullscreen,
      );
      expect(
        find.byKey(const ValueKey('global_fullscreen_overlay_slide')),
        findsOneWidget,
      );
      expect(exitInvoked, isTrue);

      exitCompleter.complete();
      await _pumpUntil(
        tester,
        () =>
            containerRef.read(playerStateProvider).fullscreenPhase ==
            FullscreenPhase.inline,
      );

      expect(
        containerRef.read(playerStateProvider).fullscreenPhase,
        FullscreenPhase.inline,
      );
      expect(
        find.byKey(const ValueKey('global_fullscreen_overlay_slide')),
        findsNothing,
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('playback resume failure does not roll back a successful exit', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    final player = _ResumeFailingPlayer();
    try {
      var exitInvoked = false;
      windowsFullscreenHandler = (call) async {
        if (call.method == 'exit') {
          exitInvoked = true;
        }
        return null;
      };
      final controller = _ExitVideoController(player);
      final mockRepo = MockGraphQLSceneRepository()..withData([testScene]);

      await pumpTestWidget(
        tester,
        prefs: prefs,
        overrides: [
          sceneRepositoryProvider.overrideWithValue(mockRepo),
          playerStateProvider.overrideWith(
            () => _ExitTestPlayerState(player, controller),
          ),
        ],
        child: const GlobalFullscreenOverlay(),
      );

      final container = tester.element(find.byType(GlobalFullscreenOverlay));
      final containerRef = ProviderScope.containerOf(container);
      containerRef.read(playerStateProvider.notifier).setFullScreen(true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      player.emitPlaying();
      await tester.pump();

      player.isPlaying = false;
      containerRef.read(playerStateProvider.notifier).requestExitFullscreen();
      await _pumpUntil(
        tester,
        () =>
            containerRef.read(playerStateProvider).fullscreenPhase !=
            FullscreenPhase.exiting,
      );

      expect(exitInvoked, isTrue);
      expect(player.playAttempts, 1);
      expect(
        containerRef.read(playerStateProvider).fullscreenPhase,
        FullscreenPhase.inline,
      );
      expect(containerRef.read(playerStateProvider).isFullScreen, isFalse);
      expect(
        find.byKey(const ValueKey('global_fullscreen_overlay_slide')),
        findsNothing,
      );
    } finally {
      await player.close();
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('native exit failure restores retryable fullscreen UI', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      var exitInvoked = false;
      windowsFullscreenHandler = (call) async {
        if (call.method == 'exit') {
          exitInvoked = true;
          throw PlatformException(
            code: 'fullscreen_error',
            message: 'Restored maximized state does not match saved state',
          );
        }
        return null;
      };
      final mockRepo = MockGraphQLSceneRepository()..withData([testScene]);

      await pumpTestWidget(
        tester,
        prefs: prefs,
        overrides: [sceneRepositoryProvider.overrideWithValue(mockRepo)],
        child: const GlobalFullscreenOverlay(),
      );
      final container = tester.element(find.byType(GlobalFullscreenOverlay));
      final containerRef = ProviderScope.containerOf(container);
      containerRef.read(playerStateProvider.notifier).setFullScreen(true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      containerRef.read(playerStateProvider.notifier).requestExitFullscreen();
      await tester.pump();
      expect(exitInvoked, isTrue);
      await _pumpUntil(
        tester,
        () =>
            containerRef.read(playerStateProvider).fullscreenPhase ==
            FullscreenPhase.fullscreen,
      );

      expect(
        containerRef.read(playerStateProvider).fullscreenPhase,
        FullscreenPhase.fullscreen,
      );
      expect(containerRef.read(playerStateProvider).isFullScreen, isTrue);
      expect(
        find.byKey(const ValueKey('global_fullscreen_overlay_slide')),
        findsOneWidget,
      );
      expect(
        AppLogStore.instance.entries.any(
          (entry) => entry.message.contains('error exiting fullscreen'),
        ),
        isTrue,
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
