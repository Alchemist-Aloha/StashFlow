// Build with --release -t test/windows/pip_smoke.dart, then run with
// scripts/test_windows_pip.py and a local video fixture.
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:multiview_desktop/multiview_desktop.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/utils/desktop_window.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';
import 'package:stash_app_flutter/core/utils/pip_mode.dart';
import 'package:stash_app_flutter/core/utils/root_app_runner.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/desktop_pip_window.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/player_view_mode.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/global_fullscreen_overlay.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

final _log = File('pip_smoke.log');

class _SmokePlayerState extends PlayerState {
  _SmokePlayerState(this.player, this.controller);

  final Player player;
  final VideoController controller;

  @override
  GlobalPlayerState build() => super.build().copyWith(
    player: player,
    videoController: controller,
    activeScene: Scene(
      id: 'pip-smoke',
      title: 'Local PiP fixture',
      date: DateTime(2026),
      rating100: null,
      oCounter: 0,
      organized: false,
      interactive: false,
      resumeTime: null,
      playCount: 0,
      playDuration: null,
      files: const [],
      paths: const ScenePaths(
        screenshot: null,
        preview: null,
        stream: null,
        vtt: null,
        sprite: null,
      ),
      urls: const [],
      studioId: null,
      studioName: null,
      studioImagePath: null,
      performerIds: const [],
      performerNames: const [],
      performerImagePaths: const [],
      tagIds: const [],
      tagNames: const [],
    ),
  );
}

void _record(String message) =>
    _log.writeAsStringSync('$message\n', mode: FileMode.append);

void _check(bool condition, String message) {
  if (!condition) throw StateError(message);
}

Future<void> _wait(bool Function() ready, String message) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (!ready()) {
    _check(DateTime.now().isBefore(deadline), message);
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

void _key(PhysicalKeyboardKey physical, LogicalKeyboardKey logical) {
  final handler = ui.PlatformDispatcher.instance.onKeyData;
  _check(handler != null, 'Keyboard dispatch unavailable');
  for (final type in [ui.KeyEventType.down, ui.KeyEventType.up]) {
    handler!(
      ui.KeyData(
        type: type,
        timeStamp: Duration.zero,
        physical: physical.usbHidUsage,
        logical: logical.keyId,
        character: null,
        synthesized: true,
      ),
    );
  }
}

Future<void> main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();
  _log.writeAsStringSync('START\n');
  FlutterError.onError = (details) {
    _record('FAIL $details\n${details.stack}');
    exit(1);
  };
  ui.PlatformDispatcher.instance.onError = (error, stack) {
    _record('FAIL $error\n$stack');
    exit(1);
  };
  try {
    _check(arguments.length == 1, 'Supply a local video fixture');
    MediaKit.ensureInitialized();
    await DesktopWindow.instance.initialize();
    final player = Player();
    final controller = VideoController(player);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        playerStateProvider.overrideWith(
          () => _SmokePlayerState(player, controller),
        ),
      ],
    );
    final notifier = container.read(playerStateProvider.notifier);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Consumer(
            builder: (context, ref, _) {
              final state = ref.watch(playerStateProvider);
              return Stack(
                fit: StackFit.expand,
                children: [
                  if (!state.isInPipMode && !state.isFullScreen)
                    Video(controller: controller, controls: null),
                  const GlobalFullscreenOverlay(),
                ],
              );
            },
          ),
        ),
      ],
    );
    // Match the production material_ui router app. The multi-window package
    // captures its inner WidgetsApp, not an SDK MaterialApp.
    runRootApp(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await Future<void>.delayed(const Duration(seconds: 1));
    await player.open(Media(arguments.single));
    await _wait(() => player.state.position.inMilliseconds > 300, 'Playback');
    await controller.waitUntilFirstFrameRendered;
    final mainWindow = MultiViewDesktop.fromId(1);
    final mainBounds = mainWindow.getBounds();
    for (var cycle = 0; cycle < 3; cycle++) {
      final fromFullscreen = cycle > 0;
      if (fromFullscreen) {
        notifier.requestEnterFullscreen();
        await _wait(
          () =>
              container.read(playerStateProvider).fullscreenPhase ==
              FullscreenPhase.fullscreen,
          'Fullscreen entry',
        );
        await Future<void>.delayed(const Duration(milliseconds: 400));
      }
      final before = player.state.position;
      _check(await notifier.requestEnterPip(), 'PiP entry failed');
      _check(
        !container.read(playerStateProvider).isFullScreen,
        'Fullscreen remained active in PiP',
      );
      await _wait(
        () => ui.PlatformDispatcher.instance.views.length == 2,
        'PiP view',
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final pipId = MultiViewDesktop.allWindowViewIds.singleWhere(
        (id) => id != 1,
      );
      final pip = MultiViewDesktop.fromId(pipId);
      _check(pip.isAlwaysOnTop(), 'PiP must stay on top');
      final size = pip.getSize();
      final ratio = pipDisplayAspectRatio(player.state.videoParams)!;
      _check((size.aspectRatio - ratio).abs() < 0.02, 'PiP ratio');
      _check(mainWindow.getBounds() == mainBounds, 'Main window changed');
      _check(player.state.position > before, 'Playback did not continue');
      pip.focus();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      _key(PhysicalKeyboardKey.space, LogicalKeyboardKey.space);
      await _wait(() => !player.state.playing, 'PiP keyboard pause');
      final paused = player.state.position;
      _key(PhysicalKeyboardKey.arrowRight, LogicalKeyboardKey.arrowRight);
      await _wait(
        () => player.state.position > paused + const Duration(seconds: 4),
        'PiP keyboard seek',
      );
      _key(PhysicalKeyboardKey.space, LogicalKeyboardKey.space);
      await _wait(() => player.state.playing, 'PiP keyboard resume');
      if (cycle == 1) {
        // Native close must reset shared PiP state just like its exit control.
        await pip.closeWindow();
      } else {
        _key(PhysicalKeyboardKey.escape, LogicalKeyboardKey.escape);
      }
      await _wait(() => !PipMode.isInPipMode.value, 'PiP state after close');
      await _wait(
        () => ui.PlatformDispatcher.instance.views.length == 1,
        'PiP view cleanup',
      );
      if (fromFullscreen) {
        await _wait(
          () => container.read(playerStateProvider).isFullScreen,
          'Fullscreen presentation was not restored',
        );
        await Future<void>.delayed(const Duration(milliseconds: 400));
        notifier.requestExitFullscreen();
        await _wait(
          () => !container.read(playerStateProvider).isFullScreen,
          'Final fullscreen exit',
        );
      }
      _check(mainWindow.getBounds() == mainBounds, 'Main window restoration');
      _record(
        'CYCLE $cycle PASS: fullscreen=$fromFullscreen, video, ratio, pause, seek, resume, close',
      );
    }
    await player.dispose();
    _record('PASS');
    exit(0);
  } on Object catch (error, stack) {
    _record('FAIL $error\n$stack');
    exit(1);
  }
}
