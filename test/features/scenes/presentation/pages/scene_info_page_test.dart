import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/data/graphql/media_headers_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/pages/scene_info_page.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_details_provider.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

class _SceneDetails extends SceneDetails {
  _SceneDetails(this.scene);

  final Scene scene;

  @override
  Future<Scene> build(String id) async => scene;
}

void main() {
  for (final size in [3221225472, 0, null]) {
    for (final scale in [0.5, 2.0]) {
      testWidgets('file size $size is shown at scale $scale', (tester) async {
        final scene = Scene(
          id: 'scene-1',
          title: 'Scene',
          date: DateTime(2026),
          rating100: null,
          oCounter: 0,
          organized: false,
          interactive: false,
          resumeTime: null,
          playCount: 0,
          playDuration: null,
          files: [
            SceneFile(
              size: size,
              format: null,
              width: null,
              height: null,
              videoCodec: null,
              audioCodec: null,
              bitRate: null,
              duration: null,
              frameRate: null,
            ),
          ],
          paths: const ScenePaths(
            screenshot: null,
            preview: null,
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
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sceneDetailsProvider(
                scene.id,
              ).overrideWith(() => _SceneDetails(scene)),
              mediaHeadersProvider.overrideWithValue(const {}),
            ],
            child: MaterialApp(
              theme: AppTheme.buildTheme(
                Brightness.dark,
                const Color(0xFF0F766E),
                fontSizeFactor: scale,
              ),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(body: SceneInfoPage(scene: scene)),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final label = find.text('File Size');
        await tester.scrollUntilVisible(
          label,
          150,
          scrollable: find.byType(Scrollable).first,
        );
        expect(label, findsOneWidget);
        expect(
          find.ancestor(of: label, matching: find.byType(SelectionArea)),
          findsOneWidget,
        );
        final row = find.ancestor(of: label, matching: find.byType(Row)).first;
        expect(
          find.descendant(
            of: row,
            matching: find.text(
              size == null
                  ? '--'
                  : size == 0
                  ? '0 B'
                  : '3.00 GB',
            ),
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
