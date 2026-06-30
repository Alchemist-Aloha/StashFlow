import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_deduplication.dart';
import 'package:stash_app_flutter/features/scenes/presentation/pages/scene_deduplication_page.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/tools/presentation/pages/tools_page.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  test('selects all but largest file using Stash codec safety', () {
    final h264Small = duplicateScene(
      id: 'small',
      fileSize: 100,
      width: 1280,
      height: 720,
      videoCodec: 'h264',
    );
    final h264Large = duplicateScene(
      id: 'large',
      fileSize: 500,
      width: 1280,
      height: 720,
      videoCodec: 'h264',
    );
    final hevc = duplicateScene(
      id: 'hevc',
      fileSize: 50,
      width: 1280,
      height: 720,
      videoCodec: 'hevc',
    );

    final safe = selectDuplicateScenes(
      groups: [
        SceneDuplicateGroup(scenes: [h264Small, h264Large]),
        SceneDuplicateGroup(scenes: [h264Small, hevc]),
      ],
      mode: DuplicateSelectionMode.allButLargestFile,
      safeSelect: true,
    );
    expect(safe, {'small'});

    final unsafe = selectDuplicateScenes(
      groups: [
        SceneDuplicateGroup(scenes: [h264Small, hevc]),
      ],
      mode: DuplicateSelectionMode.allButLargestFile,
      safeSelect: false,
    );
    expect(unsafe, {'hevc'});
  });

  test('selects all but largest resolution and skips identical resolution', () {
    final small = duplicateScene(
      id: 'small',
      fileSize: 500,
      width: 1280,
      height: 720,
      videoCodec: 'h264',
    );
    final large = duplicateScene(
      id: 'large',
      fileSize: 100,
      width: 3840,
      height: 2160,
      videoCodec: 'h264',
    );
    final sameResolution = duplicateScene(
      id: 'same',
      fileSize: 50,
      width: 1280,
      height: 720,
      videoCodec: 'h264',
    );

    final selected = selectDuplicateScenes(
      groups: [
        SceneDuplicateGroup(scenes: [small, large]),
        SceneDuplicateGroup(scenes: [small, sameResolution]),
      ],
      mode: DuplicateSelectionMode.allButLargestResolution,
      safeSelect: true,
    );

    expect(selected, {'small'});
  });

  test('selects all but oldest and youngest by first file mod time', () {
    final old = duplicateScene(
      id: 'old',
      modTime: DateTime(2020),
      videoCodec: 'h264',
    );
    final young = duplicateScene(
      id: 'young',
      modTime: DateTime(2024),
      videoCodec: 'h264',
    );
    final middle = duplicateScene(
      id: 'middle',
      modTime: DateTime(2022),
      videoCodec: 'h264',
    );

    expect(
      selectDuplicateScenes(
        groups: [
          SceneDuplicateGroup(scenes: [old, middle, young]),
        ],
        mode: DuplicateSelectionMode.allButOldest,
        safeSelect: true,
      ),
      {'middle', 'young'},
    );
    expect(
      selectDuplicateScenes(
        groups: [
          SceneDuplicateGroup(scenes: [old, middle, young]),
        ],
        mode: DuplicateSelectionMode.allButYoungest,
        safeSelect: true,
      ),
      {'old', 'middle'},
    );
  });

  testWidgets('ToolsPage links to Scene Deduplication subpage', (tester) async {
    final router = GoRouter(
      initialLocation: '/tools',
      routes: [
        GoRoute(
          path: '/tools',
          builder: (context, state) => const ToolsPage(),
          routes: [
            GoRoute(
              path: 'scene-deduplication',
              builder: (context, state) =>
                  const Scaffold(body: Text('Dedup target')),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );

    await tester.tap(find.text('Scene Deduplication'));
    await tester.pumpAndSettle();

    expect(find.text('Dedup target'), findsOneWidget);
  });

  testWidgets('SceneDeduplicationPage loads Stash default duplicate query', (
    tester,
  ) async {
    final repo = MockGraphQLSceneRepository()
      ..duplicateGroups = [
        SceneDuplicateGroup(
          scenes: [
            duplicateScene(id: 'a', fileSize: 200),
            duplicateScene(id: 'b', fileSize: 100),
          ],
        ),
      ]
      ..missingPhashCount = 3;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          sceneRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          locale: const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hans',
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          home: const SceneDeduplicationPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(repo.lastDuplicateDistance, 0);
    expect(repo.lastDuplicateDurationDiff, 1);
    expect(repo.duplicateFetchCount, 1);
    expect(find.byIcon(Icons.warning_amber), findsOneWidget);
    expect(find.byKey(const ValueKey('duplicate_group_1')), findsOneWidget);
    expect(find.text('Scene a'), findsOneWidget);
    expect(find.text('Scene b'), findsOneWidget);
  });

  testWidgets(
    'SceneDeduplicationPage stacks duplicate scene actions on mobile',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);

      final repo = MockGraphQLSceneRepository()
        ..duplicateGroups = [
          SceneDuplicateGroup(
            scenes: [
              duplicateScene(id: 'a', fileSize: 200),
              duplicateScene(id: 'b', fileSize: 100),
            ],
          ),
        ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            sceneRepositoryProvider.overrideWithValue(repo),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.lightTheme,
            home: const SceneDeduplicationPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final openScene = find.byTooltip('Open scene').first;
      final deleteScene = find.byTooltip('Delete').first;
      final openTopLeft = tester.getTopLeft(openScene);
      final deleteTopLeft = tester.getTopLeft(deleteScene);

      expect(deleteTopLeft.dx, openTopLeft.dx);
      expect(deleteTopLeft.dy, greaterThan(openTopLeft.dy));
    },
  );
}

SceneDuplicateScene duplicateScene({
  required String id,
  int fileSize = 0,
  int width = 1920,
  int height = 1080,
  int bitRate = 0,
  double duration = 60,
  String? videoCodec,
  DateTime? modTime,
}) {
  return SceneDuplicateScene(
    id: id,
    title: 'Scene $id',
    path: '/media/$id.mp4',
    spritePath: null,
    organized: false,
    oCounter: 0,
    tagCount: 0,
    performerCount: 0,
    groupCount: 0,
    markerCount: 0,
    galleryCount: 0,
    fileCount: 1,
    files: [
      SceneDuplicateFile(
        id: 'file-$id',
        path: '/media/$id.mp4',
        size: fileSize,
        width: width,
        height: height,
        bitRate: bitRate,
        duration: duration,
        videoCodec: videoCodec,
        modTime: modTime,
      ),
    ],
  );
}
