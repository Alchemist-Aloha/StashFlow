import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/playback_queue_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/playlist_floating_panel.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

class _TestPlaybackQueue extends PlaybackQueue {
  _TestPlaybackQueue(this.scenes);

  final List<Scene> scenes;

  @override
  PlaybackQueueState build() =>
      PlaybackQueueState(sequence: scenes, currentIndex: 20);
}

Scene _scene(int index) => Scene(
  id: '$index',
  title: 'Scene $index',
  date: DateTime(2024, 1, 1),
  rating100: null,
  oCounter: 0,
  organized: false,
  interactive: false,
  resumeTime: 0,
  playCount: 0,
  playDuration: 0,
  files: const [],
  paths: const ScenePaths(screenshot: null, preview: null, stream: null),
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

void main() {
  testWidgets('playlist opens focused on the playing item', (tester) async {
    final scenes = List.generate(40, _scene);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playbackQueueProvider.overrideWith(() => _TestPlaybackQueue(scenes)),
        ],
        child: MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: PlaylistFloatingPanel()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final activeTitle = find.text('21. Scene 20');
    expect(activeTitle, findsOneWidget);
    final activeInkWell = tester.widget<InkWell>(
      find.ancestor(of: activeTitle, matching: find.byType(InkWell)).first,
    );
    expect(activeInkWell.focusNode?.hasFocus, isTrue);
    expect(
      tester.widget<ListView>(find.byType(ListView)).controller!.offset,
      greaterThan(0),
    );
  });
}
