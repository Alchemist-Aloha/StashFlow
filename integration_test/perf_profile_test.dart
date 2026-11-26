/// Frame-timing profile of the real app against a stash-test-server library.
///
/// Records engine `FrameTiming` (build, raster, total span), RSS and image
/// cache occupancy per scenario and reports them to `test_driver/perf_driver.dart`:
///
/// ```bash
/// set -a; source ../stash-test-server/stash-test-server.env; set +a
/// PERF_OUT=perf_linux flutter drive --profile -d linux \
///   --driver=test_driver/perf_driver.dart \
///   --target=integration_test/perf_profile_test.dart \
///   --dart-define="STASH_URL=$STASH_URL" \
///   --dart-define="STASH_API_KEY=$STASH_API_KEY"
/// ```
///
/// On the Android emulator pass `STASH_URL=http://10.0.2.2:9999`.
library;

import 'dart:async';
import 'dart:io' show Platform, ProcessInfo;
import 'dart:ui' show FrameTiming, PlatformDispatcher;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/one_time_tips.dart';
import 'package:stash_app_flutter/features/galleries/presentation/widgets/gallery_card.dart';
import 'package:stash_app_flutter/features/images/presentation/widgets/image_card.dart';
import 'package:stash_app_flutter/features/navigation/presentation/widgets/mini_player.dart';
import 'package:stash_app_flutter/features/performers/presentation/widgets/performer_card.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/player_settings.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/player_surface.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_card.dart';
import 'package:stash_app_flutter/features/setup/presentation/widgets/server_profile_drawer.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import 'package:stash_app_flutter/main.dart' as app;
import 'package:wakelock_plus/wakelock_plus.dart';

const _url = String.fromEnvironment('STASH_URL');
const _apiKey = String.fromEnvironment('STASH_API_KEY');
const _sceneTitle = 'Pocket Garden';
const _frameBudgetUs = 16667;

Finder _field(String label) =>
    find.ancestor(of: find.text(label), matching: find.byType(TextField));

Future<void> _pumpUntil(
  WidgetTester tester,
  bool Function() condition,
  String description, {
  Duration timeout = const Duration(seconds: 60),
}) async {
  final deadline = DateTime.now().add(timeout);
  do {
    await tester.pump(const Duration(milliseconds: 100));
    if (condition()) return;
  } while (DateTime.now().isBefore(deadline));
  final onScreen = find
      .byType(RichText)
      .evaluate()
      .map((e) => (e.widget as RichText).text.toPlainText())
      .where((t) => t.trim().isNotEmpty)
      .take(60)
      .toList();
  throw TestFailure('Timed out waiting for $description\nOn screen: $onScreen');
}

Future<void> _pumpFor(
  WidgetTester tester,
  Finder finder, {
  bool gone = false,
}) => _pumpUntil(tester, () => finder.evaluate().isEmpty == gone, '$finder');

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await _pumpFor(tester, finder);
  await _pumpUntil(tester, () {
    if (finder.hitTestable().evaluate().isNotEmpty) return true;
    unawaited(Scrollable.ensureVisible(tester.element(finder.first)));
    return false;
  }, '${finder.hitTestable()}');
  await tester.tap(finder.hitTestable().first);
}

GoRouter _router(WidgetTester tester) =>
    GoRouter.of(tester.element(find.byType(Scaffold).first));

String _location(WidgetTester tester) =>
    _router(tester).routerDelegate.currentConfiguration.last.matchedLocation;

Future<void> _backTo(WidgetTester tester, String path) async {
  for (var i = 0; i < 4 && _location(tester) != path; i++) {
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 500));
  }
  expect(_location(tester), path);
}

double _pct(List<int> sorted, double p) =>
    sorted.isEmpty ? 0 : sorted[((sorted.length - 1) * p).round()] / 1000;

Map<String, Object> _summarize(List<FrameTiming> frames, Duration elapsed) {
  List<int> sorted(int Function(FrameTiming) f) =>
      frames.map(f).toList()..sort();
  final build = sorted((f) => f.buildDuration.inMicroseconds);
  final raster = sorted((f) => f.rasterDuration.inMicroseconds);
  final total = sorted((f) => f.totalSpan.inMicroseconds);
  final cache = PaintingBinding.instance.imageCache;
  double r(double v) => (v * 100).roundToDouble() / 100;
  return {
    'frames': frames.length,
    'elapsed_ms': elapsed.inMilliseconds,
    'fps': r(frames.length * 1000 / elapsed.inMilliseconds.clamp(1, 1 << 30)),
    'build_p50': r(_pct(build, .5)),
    'build_p90': r(_pct(build, .9)),
    'build_max': r(_pct(build, 1)),
    'raster_p50': r(_pct(raster, .5)),
    'raster_p90': r(_pct(raster, .9)),
    'raster_max': r(_pct(raster, 1)),
    'total_p50': r(_pct(total, .5)),
    'total_p90': r(_pct(total, .9)),
    'total_p99': r(_pct(total, .99)),
    'total_max': r(_pct(total, 1)),
    'jank_pct': r(
      frames.isEmpty
          ? 0
          : 100 * total.where((t) => t > _frameBudgetUs).length / frames.length,
    ),
    'rss_mb': r(ProcessInfo.currentRss / (1 << 20)),
    'image_cache_mb': r(cache.currentSizeBytes / (1 << 20)),
    'image_cache_live': cache.liveImageCount,
  };
}

class _IsolatedSupportPath extends PathProviderPlatform {
  _IsolatedSupportPath(this.inner, this.supportPath);

  final PathProviderPlatform inner;
  final String supportPath;

  @override
  Future<String> getApplicationSupportPath() async => supportPath;

  @override
  Future<String?> getTemporaryPath() => inner.getTemporaryPath();

  @override
  Future<String?> getApplicationCachePath() => inner.getApplicationCachePath();

  @override
  Future<String?> getApplicationDocumentsPath() =>
      inner.getApplicationDocumentsPath();
}

class _NoopWakelock implements WakelockPlusLinuxPlugin {
  @override
  bool get isMock => true;

  @override
  Future<void> toggle({required bool enable}) async {}

  @override
  Future<bool> get enabled async => false;
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'profiles frame timings across the main surfaces',
    skip: _url.isEmpty,
    timeout: const Timeout(Duration(minutes: 15)),
    (tester) async {
      final platform = PathProviderPlatform.instance;
      final cacheDir = await getTemporaryDirectory();
      await cacheDir.create(recursive: true);
      final support = await cacheDir.createTemp('stashflow-perf-support-');
      addTearDown(() => support.delete(recursive: true));
      PathProviderPlatform.instance = _IsolatedSupportPath(
        platform,
        support.path,
      );
      addTearDown(() => PathProviderPlatform.instance = platform);
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({
        'app_language': 'en',
        'last_app_update_check_timestamp':
            DateTime.now().millisecondsSinceEpoch,
        for (final tip in OneTimeTip.values) tip.key: false,
        // Keep the player alive across the idle and scroll scenarios.
        PlayerSettingsStore.playEndBehaviorKey: 'loop',
      });
      if (Platform.isLinux) {
        final wakelock = wakelockPlusPlatformInstance;
        wakelockPlusPlatformInstance = _NoopWakelock();
        addTearDown(() => wakelockPlusPlatformInstance = wakelock);
      }
      final l10n = lookupAppLocalizations(const Locale('en'));
      // The integration binding leaves text input to the platform; register the
      // test hook so enterText works under `flutter drive`.
      tester.testTextInput.register();
      addTearDown(tester.testTextInput.unregister);

      final frames = <FrameTiming>[];
      void onTimings(List<FrameTiming> t) => frames.addAll(t);
      SchedulerBinding.instance.addTimingsCallback(onTimings);
      addTearDown(
        () => SchedulerBinding.instance.removeTimingsCallback(onTimings),
      );

      final results = <String, Object>{};
      // Set while a video plays, to prove playback advanced during a scenario.
      Duration Function()? videoPosition;
      Future<void> scenario(String name, Future<void> Function() action) async {
        // Release/profile engines batch FrameTiming reports about once a second.
        await tester.pump(const Duration(milliseconds: 1200));
        frames.clear();
        // Debug runs also attribute rebuilds, to find what drives the frames.
        final rebuilds = <String, int>{};
        if (kDebugMode) {
          debugOnRebuildDirtyWidget = (element, _) {
            final type = element.widget.runtimeType.toString();
            rebuilds[type] = (rebuilds[type] ?? 0) + 1;
          };
        }
        final videoStart = videoPosition?.call();
        final watch = Stopwatch()..start();
        await action();
        final videoEnd = videoPosition?.call();
        watch.stop();
        debugOnRebuildDirtyWidget = null;
        await tester.pump(const Duration(milliseconds: 1200));
        final summary = _summarize(List.of(frames), watch.elapsed);
        if (kDebugMode) {
          final top = rebuilds.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          summary['rebuilds'] = {for (final e in top.take(12)) e.key: e.value};
        }
        if (videoStart != null && videoEnd != null) {
          summary['video_advance_ms'] = (videoEnd - videoStart).inMilliseconds;
        }
        results[name] = summary;
        debugPrint('PERF $name $summary');
      }

      Size screen() => tester.view.physicalSize / tester.view.devicePixelRatio;
      Future<void> dragBursts({int times = 3, Offset? at}) async {
        final size = screen();
        final from = at ?? Offset(size.width / 2, size.height * .6);
        final dy = size.height * .45;
        for (final dir in [-1.0, 1.0]) {
          for (var i = 0; i < times; i++) {
            await tester.timedDragFrom(
              from - Offset(0, dir * dy / 2),
              Offset(0, dir * dy),
              const Duration(milliseconds: 400),
            );
            await tester.pump(const Duration(milliseconds: 300));
          }
        }
      }

      final onError = FlutterError.onError;
      final onPlatformError = PlatformDispatcher.instance.onError;
      final print = debugPrint;
      final startup = Stopwatch()..start();
      try {
        await app.main();
      } finally {
        FlutterError.onError = onError;
        PlatformDispatcher.instance.onError = onPlatformError;
        debugPrint = print;
      }

      await _tap(
        tester,
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(l10n.common_configure_now),
        ),
      );
      await _tap(tester, find.byTooltip(l10n.settings_server_profile_add));
      await _pumpFor(tester, _field(l10n.common_url));
      await tester.enterText(_field(l10n.settings_server_profile_name), 'perf');
      await tester.enterText(_field(l10n.common_url), _url);
      await tester.enterText(_field(l10n.settings_server_auth_apikey), _apiKey);
      final drawer = find.byType(ServerProfileDrawer);
      await _tap(tester, find.text(l10n.settings_server_test));
      await _pumpFor(
        tester,
        find.descendant(
          of: drawer,
          matching: find.textContaining(RegExp(r'^(v?\d+\.\d+|Error)')),
        ),
      );
      await _tap(tester, find.text(l10n.common_save));
      await _pumpFor(tester, _field(l10n.common_url), gone: true);
      // Text entry needs explicit pumps; measure with real vsync-driven frames
      // so FrameTiming reflects what a user would see.
      binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
      startup.reset();
      await _backTo(tester, '/scenes');
      final sceneCard = find.byWidgetPredicate(
        (w) => w is SceneCard && w.scene.title == _sceneTitle,
      );

      await scenario('00_profile_to_scenes', () async {
        await _pumpFor(tester, sceneCard);
      });
      results['00_profile_to_scenes_ms'] = startup.elapsedMilliseconds;
      // Let thumbnails finish decoding before measuring steady scrolling.
      await tester.pump(const Duration(seconds: 3));

      await scenario(
        '01_scenes_idle',
        () => tester.pump(const Duration(seconds: 4)),
      );
      await scenario('02_scenes_scroll', dragBursts);
      await scenario('03_filter_sort_sheets', () async {
        for (final icon in [Icons.filter_list, Icons.sort]) {
          await _tap(tester, find.byIcon(icon));
          await tester.pump(const Duration(milliseconds: 900));
          await tester.binding.handlePopRoute();
          await tester.pump(const Duration(milliseconds: 700));
        }
      });

      final surface = find.byWidgetPredicate(
        (w) => w is PlayerSurface && w.showControls,
      );
      final miniPlayer = find.byType(MiniPlayer);
      late final PlayerSurface player;
      await scenario('04_scene_details_open', () async {
        await _tap(tester, sceneCard);
        await _pumpFor(tester, surface);
        player = tester.widget<PlayerSurface>(surface);
        videoPosition = () => player.controller.player.state.position;
        await _pumpUntil(
          tester,
          () => (player.controller.player.state.width ?? 0) > 0,
          'first decoded video frame',
        );
      });
      // Controls are visible right after open; autohide is 2 s by default.
      await scenario(
        '05_video_idle_controls_visible',
        () => tester.pump(const Duration(milliseconds: 1500)),
      );
      await tester.pump(const Duration(seconds: 3));
      await scenario(
        '06_video_idle_controls_hidden',
        () => tester.pump(const Duration(seconds: 4)),
      );
      final handle = find.byKey(const Key('scene_panel_handle'));
      await scenario('07_scene_panel_drag', () async {
        for (final dy in [-250.0, 250.0, -250.0, 250.0]) {
          await tester.timedDrag(
            handle.first,
            Offset(0, dy),
            const Duration(milliseconds: 400),
          );
          await tester.pump(const Duration(milliseconds: 400));
        }
      });
      final panel = find.byKey(const Key('scene_details_panel'));
      await scenario('08_scene_details_scroll', () async {
        final box = tester.getRect(panel);
        await dragBursts(times: 2, at: box.center);
      });

      await _backTo(tester, '/scenes');
      await _pumpFor(tester, miniPlayer);
      await tester.pump(const Duration(seconds: 1));
      await scenario(
        '09_scenes_idle_with_mini_player',
        () => tester.pump(const Duration(seconds: 4)),
      );
      await scenario('10_scenes_scroll_with_mini_player', dragBursts);

      await _tap(
        tester,
        find.descendant(
          of: miniPlayer,
          matching: find.byTooltip(l10n.common_close),
        ),
      );
      await _pumpFor(tester, miniPlayer, gone: true);
      videoPosition = null;
      final notifier = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold).first),
      ).read(playerStateProvider.notifier);
      await _pumpUntil(
        tester,
        () => notifier.currentVideoController == null,
        'player release',
      );

      Finder navTab(IconData icon) => find.descendant(
        of: find.byWidgetPredicate(
          (w) => w is NavigationBar || w is NavigationRail,
        ),
        matching: find.byIcon(icon),
      );
      final tabs = <(String, IconData, Finder)>[
        ('performers', Icons.people, find.byType(PerformerCard)),
        ('studios', Icons.business, find.text('Aurora Pictures')),
        ('tags', Icons.local_offer, find.text('Fractal')),
        ('galleries', Icons.perm_media, find.byType(GalleryCard)),
      ];
      var index = 11;
      for (final (name, icon, ready) in tabs) {
        await scenario('${index++}_${name}_tab_open', () async {
          await tester.tap(navTab(icon).first);
          await _pumpFor(tester, ready);
          await tester.pump(const Duration(seconds: 1));
        });
        await scenario('${index++}_${name}_tab_scroll', dragBursts);
      }

      await scenario('19_gallery_details_open_scroll', () async {
        await _tap(tester, find.byType(GalleryCard).first);
        await tester.pump(const Duration(seconds: 2));
        await dragBursts(times: 2);
      });
      await _backTo(tester, '/galleries');

      await scenario('20_tab_switch_churn', () async {
        for (var i = 0; i < 2; i++) {
          for (final icon in [
            Icons.people,
            Icons.business,
            Icons.local_offer,
            Icons.perm_media,
          ]) {
            await tester.tap(navTab(icon).first);
            await tester.pump(const Duration(milliseconds: 500));
          }
        }
      });

      unawaited(_router(tester).push('/galleries/images'));
      await _pumpFor(tester, find.byType(ImageCard));
      await tester.pump(const Duration(seconds: 2));
      await scenario('21_images_scroll', dragBursts);
      await scenario('22_image_viewer_swipe', () async {
        await _tap(tester, find.byType(ImageCard).first);
        await tester.pump(const Duration(seconds: 2));
        final size = screen();
        for (final dir in [-1.0, -1.0, -1.0, 1.0, 1.0, 1.0]) {
          await tester.timedDragFrom(
            Offset(size.width / 2 - dir * size.width * .3, size.height / 2),
            Offset(dir * size.width * .6, 0),
            const Duration(milliseconds: 300),
          );
          await tester.pump(const Duration(milliseconds: 700));
        }
      });

      results['platform'] = Platform.operatingSystem;
      results['screen'] = '${screen()} @${tester.view.devicePixelRatio}';
      binding.reportData = results;
    },
  );
}
