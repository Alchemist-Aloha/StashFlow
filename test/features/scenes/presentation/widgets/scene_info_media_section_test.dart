import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_info_media_section.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

void main() {
  final baseScene = Scene(
    id: 'scene-1',
    title: 'Scene',
    date: DateTime(2026, 6, 11),
    rating100: null,
    oCounter: 0,
    organized: false,
    interactive: false,
    resumeTime: null,
    playCount: 0,
    playDuration: null,
    files: const [],
    paths: const ScenePaths(
      screenshot: 'https://example.com/cover.jpg',
      preview: 'https://example.com/preview.mp4',
      stream: null,
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

  Widget buildSubject(
    Scene scene, {
    void Function(bool autoplay)? onPreviewBuilt,
  }) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SceneInfoMediaSection(
            scene: scene,
            coverBuilder: (context, scene) =>
                const ColoredBox(color: Colors.blue),
            previewBuilder: (context, scene, autoplay) {
              onPreviewBuilt?.call(autoplay);
              return const ColoredBox(color: Colors.red);
            },
          ),
        ),
      ),
    );
  }

  testWidgets('both assets show toggle and default to cover', (tester) async {
    bool? previewAutoplay;
    await tester.pumpWidget(
      buildSubject(
        baseScene,
        onPreviewBuilt: (autoplay) => previewAutoplay = autoplay,
      ),
    );

    expect(find.byKey(const Key('scene_info_media_section')), findsOneWidget);
    expect(find.byKey(const Key('scene_info_media_toggle')), findsOneWidget);
    expect(find.byKey(const Key('scene_info_media_cover')), findsOneWidget);
    expect(find.byKey(const Key('scene_info_media_preview')), findsNothing);

    final toggle = find.byKey(const Key('scene_info_media_toggle'));
    await tester.tap(
      find.descendant(of: toggle, matching: find.text('Preview')),
    );
    await tester.pump();

    expect(find.byKey(const Key('scene_info_media_cover')), findsNothing);
    expect(find.byKey(const Key('scene_info_media_preview')), findsOneWidget);
    expect(previewAutoplay, isTrue);

    await tester.tap(find.descendant(of: toggle, matching: find.text('Cover')));
    await tester.pump();

    expect(find.byKey(const Key('scene_info_media_cover')), findsOneWidget);
    expect(find.byKey(const Key('scene_info_media_preview')), findsNothing);
  });

  testWidgets('tapping cover opens and closes fullscreen viewer', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(baseScene));

    await tester.tap(
      find.byKey(const Key('scene_info_media_cover_tap_target')),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      find.byKey(const Key('scene_cover_fullscreen_viewer')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const Key('scene_cover_fullscreen_exit_button')),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      find.byKey(const Key('scene_cover_fullscreen_viewer')),
      findsNothing,
    );
    expect(find.byKey(const Key('scene_info_media_section')), findsOneWidget);
  });

  testWidgets('tapping preview does not open cover fullscreen viewer', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(baseScene));

    final toggle = find.byKey(const Key('scene_info_media_toggle'));
    await tester.tap(
      find.descendant(of: toggle, matching: find.text('Preview')),
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('scene_info_media_preview')));
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      find.byKey(const Key('scene_cover_fullscreen_viewer')),
      findsNothing,
    );
  });

  testWidgets('cover-only scene shows cover without toggle', (tester) async {
    final scene = baseScene.copyWith(
      paths: baseScene.paths.copyWith(preview: null),
    );

    await tester.pumpWidget(buildSubject(scene));

    expect(find.byKey(const Key('scene_info_media_section')), findsOneWidget);
    expect(find.byKey(const Key('scene_info_media_toggle')), findsNothing);
    expect(find.byKey(const Key('scene_info_media_cover')), findsOneWidget);
    expect(find.byKey(const Key('scene_info_media_preview')), findsNothing);
  });

  testWidgets('preview-only scene autoplays preview without toggle', (
    tester,
  ) async {
    bool? previewAutoplay;
    final scene = baseScene.copyWith(
      paths: baseScene.paths.copyWith(screenshot: null),
    );

    await tester.pumpWidget(
      buildSubject(
        scene,
        onPreviewBuilt: (autoplay) => previewAutoplay = autoplay,
      ),
    );

    expect(find.byKey(const Key('scene_info_media_section')), findsOneWidget);
    expect(find.byKey(const Key('scene_info_media_toggle')), findsNothing);
    expect(find.byKey(const Key('scene_info_media_cover')), findsNothing);
    expect(find.byKey(const Key('scene_info_media_preview')), findsOneWidget);
    expect(previewAutoplay, isTrue);
  });

  testWidgets('scene without cover or preview hides media section', (
    tester,
  ) async {
    final scene = baseScene.copyWith(
      paths: baseScene.paths.copyWith(screenshot: null, preview: null),
    );

    await tester.pumpWidget(buildSubject(scene));

    expect(find.byKey(const Key('scene_info_media_section')), findsNothing);
    expect(find.byKey(const Key('scene_info_media_toggle')), findsNothing);
    expect(find.byKey(const Key('scene_info_media_cover')), findsNothing);
    expect(find.byKey(const Key('scene_info_media_preview')), findsNothing);
  });
}
