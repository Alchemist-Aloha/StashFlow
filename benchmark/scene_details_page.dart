import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/pages/scene_details_page.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_video_player.dart';

import '../test/helpers/test_helpers.dart';

/// Counts element rebuilds per frame while the scene panel moves and scrolls.
///
/// Run with `flutter test benchmark/scene_details_page.dart`; widget tests do
/// not give real frame times, so rebuild counts are the comparable signal.
void main() {
  for (final size in const [Size(400, 800), Size(1440, 900)]) {
    testWidgets('scene details stays cheap to drag and scroll at $size', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final repo = MockGraphQLSceneRepository()..withData([_scene]);
      await pumpTestWidget(
        tester,
        overrides: [sceneRepositoryProvider.overrideWithValue(repo)],
        child: SceneDetailsPage(sceneId: _scene.id),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      final counts = <String, int>{};
      var total = 0;
      debugOnRebuildDirtyWidget = (element, builtOnce) {
        total++;
        final name = element.widget.runtimeType.toString();
        counts[name] = (counts[name] ?? 0) + 1;
      };
      addTearDown(() => debugOnRebuildDirtyWidget = null);

      Future<int> measure(String label, Future<void> Function() action) async {
        counts.clear();
        total = 0;
        final watch = Stopwatch()..start();
        await action();
        watch.stop();
        final top =
            (counts.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value)))
                .where(
                  (e) => const {
                    'SceneVideoPlayer',
                    'PlayerSurface',
                    'NativeVideoControls',
                    'SceneDetailsPage',
                    '_ScenePanelLayout',
                    'FrostedPanel',
                    'DetailPageScrollView',
                    'SectionPanel',
                    'SceneInfoPage',
                    'RefreshIndicator',
                    'ScrollConfiguration',
                    'LayoutBuilder',
                    'IconButton',
                    'Stack',
                    'Positioned',
                  }.contains(e.key),
                )
                .map((e) => '${e.key}=${e.value}')
                .join(', ');
        debugPrint(
          '[bench] $size $label: $total rebuilds '
          'in ${watch.elapsedMilliseconds}ms; top: $top',
        );
        return total;
      }

      final video = tester.getRect(find.byType(SceneVideoPlayer));
      final handle = find.byKey(const Key('scene_panel_handle'));
      Future<void> dragFrames(Offset start, Offset step) async {
        final gesture = await tester.startGesture(start);
        for (var i = 0; i < 30; i++) {
          await gesture.moveBy(step);
          await tester.pump(const Duration(milliseconds: 16));
        }
        await gesture.up();
        await tester.pump();
      }

      final idle = await measure('idle 30 frames', () async {
        for (var i = 0; i < 30; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
      });
      final handleDrag = await measure(
        'handle drag 30 frames',
        () => dragFrames(tester.getCenter(handle), const Offset(0, -6)),
      );
      final contentScroll = await measure(
        'content scroll 30 frames',
        () => dragFrames(
          tester.getCenter(handle) + const Offset(0, 120),
          const Offset(0, -6),
        ),
      );
      final videoSwipe = await measure(
        'video swipe 30 frames',
        () => dragFrames(
          video.center + Offset(video.width / 4, 0),
          const Offset(0, 4),
        ),
      );

      // Idle frames and panel moves must not rebuild the page or its player;
      // one page rebuild alone costs well over 1000 element rebuilds.
      expect(idle, lessThan(200));
      expect(handleDrag, lessThan(400));
      expect(contentScroll, lessThan(400));
      expect(videoSwipe, lessThan(400));
    });
  }
}

final _scene = Scene(
  id: 's1',
  title: 'Benchmark Scene',
  details: List.filled(40, 'Long scene description.').join(' '),
  date: DateTime(2024, 1, 1),
  rating100: 60,
  oCounter: 3,
  organized: true,
  interactive: false,
  resumeTime: null,
  playCount: 4,
  playDuration: 0,
  files: const [],
  paths: const ScenePaths(
    screenshot: null,
    preview: null,
    stream: 'http://localhost:9999/stream.mp4',
  ),
  urls: const [],
  studioId: 'st1',
  studioName: 'Benchmark Studio',
  studioImagePath: null,
  performerIds: List.generate(12, (i) => 'p$i'),
  performerNames: List.generate(12, (i) => 'Performer $i'),
  performerImagePaths: List.filled(12, null),
  tagIds: List.generate(30, (i) => 't$i'),
  tagNames: List.generate(30, (i) => 'Tag $i'),
);
