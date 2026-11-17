import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:media_kit/media_kit.dart' as mk;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/graphql/media_headers_provider.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/stream_resolver.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/video_controls/scene_stream_menu.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

const _base = 'http://stash.test/scene/7';
const _streams = [
  StreamChoice(
    url: '$_base/stream',
    mimeType: 'video/mp4',
    label: 'Direct stream',
  ),
  StreamChoice(
    url: '$_base/stream.mp4?resolution=ORIGINAL',
    mimeType: 'video/mp4',
    label: 'MP4',
  ),
  StreamChoice(
    url: '$_base/stream.mp4?resolution=LOW',
    mimeType: 'video/mp4',
    label: 'MP4 Low (240p)',
  ),
  StreamChoice(
    url: '$_base/stream.m3u8?resolution=ORIGINAL',
    mimeType: 'application/vnd.apple.mpegurl',
    label: 'HLS',
  ),
  StreamChoice(
    url: '$_base/stream.m3u8?resolution=LOW',
    mimeType: 'application/vnd.apple.mpegurl',
    label: 'HLS Low (240p)',
  ),
];

class _FakePlayer extends Mock implements mk.Player {
  _FakePlayer(this.url);
  String url;
  final opened = <String>[];

  @override
  mk.PlayerState get state => mk.PlayerState(
    playlist: mk.Playlist([mk.Media(url)]),
    position: const Duration(seconds: 20),
  );

  @override
  Future<void> open(mk.Playable playable, {bool play = true}) async {
    url = (playable as mk.Media).uri;
    opened.add(url);
  }
}

class _FakeController extends Mock implements VideoController {
  _FakeController(this.player);
  @override
  final mk.Player player;
}

Future<_FakePlayer> _pump(
  WidgetTester tester,
  String current, {
  double scale = 1.0,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final player = _FakePlayer(current);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        mediaPlaybackHeadersProvider.overrideWithValue(const {}),
        sceneStreamsProvider.overrideWith((ref, arg) => _streams),
      ],
      child: MaterialApp(
        theme: AppTheme.buildTheme(
          Brightness.light,
          Colors.blue,
          fontSizeFactor: scale,
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SceneStreamMenu(
            controller: _FakeController(player),
            scene: _scene,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.tap(find.byIcon(Icons.tune_rounded));
  await tester.pumpAndSettle();
  return player;
}

void main() {
  testWidgets('Apply switches to the staged resolution', (tester) async {
    final player = await _pump(tester, '$_base/stream.mp4?resolution=ORIGINAL');

    expect(find.text('Stream source'), findsOneWidget);
    expect(find.text('Resolution'), findsOneWidget);
    await tester.tap(find.text('Low (240p)'));
    await tester.pump();
    expect(player.opened, isEmpty, reason: 'staged, not applied yet');

    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(player.opened, ['$_base/stream.mp4?resolution=LOW']);
  });

  testWidgets('changing source keeps resolution and dismissal applies it', (
    tester,
  ) async {
    final player = await _pump(tester, '$_base/stream.mp4?resolution=LOW');

    await tester.tap(find.text('HLS'));
    await tester.pump();
    await tester.tapAt(const Offset(5, 590));
    await tester.pumpAndSettle();

    expect(player.opened, ['$_base/stream.m3u8?resolution=LOW']);
  });

  testWidgets('fits a phone at the largest scale', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pump(tester, '$_base/stream.m3u8?resolution=LOW', scale: 1.5);

    expect(tester.takeException(), isNull);
    expect(find.text('Apply'), findsOneWidget);
  });

  testWidgets('Direct greys out resolutions; closing unchanged is a no-op', (
    tester,
  ) async {
    final player = await _pump(tester, '$_base/stream');

    await tester.tap(find.text('Low (240p)'));
    await tester.pump();
    await tester.tapAt(const Offset(5, 590));
    await tester.pumpAndSettle();

    expect(player.opened, isEmpty);
  });
}

final _scene = Scene(
  id: '7',
  title: 'Scene',
  date: DateTime(2026),
  rating100: null,
  oCounter: 0,
  organized: false,
  interactive: false,
  resumeTime: null,
  playCount: 0,
  playDuration: 0,
  files: const [],
  paths: const ScenePaths(
    screenshot: null,
    preview: null,
    stream: '$_base/stream',
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
);
