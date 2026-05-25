import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/playback_activity_tracker.dart';

void main() {
  group('PlaybackActivityTracker', () {
    test(
      'increments play count after 5 seconds and refreshes scene details',
      () {
        fakeAsync((async) {
          var now = DateTime(2026, 1, 1, 0, 0, 0);
          var incrementCalls = 0;
          var refreshCalls = 0;

          final tracker = PlaybackActivityTracker(
            now: () => now,
            isMounted: () => true,
            incrementPlayCount: (_) async {
              incrementCalls++;
            },
            saveSceneActivity: (sceneId, resumeTime, playDuration) async {},
            refreshSceneDetails: (_) {
              refreshCalls++;
            },
            log: (_) {},
          );

          tracker.start(
            sceneId: 'scene-1',
            resumePositionProvider: () => Duration.zero,
          );

          async.elapse(const Duration(seconds: 5));
          async.flushMicrotasks();

          expect(incrementCalls, 1);
          expect(refreshCalls, 1);

          tracker.dispose();
        });
      },
    );

    test(
      'saves accumulated duration and resume position when stopped',
      () async {
        var now = DateTime(2026, 1, 1, 0, 0, 0);
        String? savedSceneId;
        double? savedResume;
        double? savedDuration;

        final tracker = PlaybackActivityTracker(
          now: () => now,
          isMounted: () => true,
          incrementPlayCount: (_) async {},
          saveSceneActivity: (sceneId, resumeTime, playDuration) async {
            savedSceneId = sceneId;
            savedResume = resumeTime;
            savedDuration = playDuration;
          },
          refreshSceneDetails: (_) {},
          log: (_) {},
        );

        tracker.start(
          sceneId: 'scene-2',
          resumePositionProvider: () => const Duration(seconds: 42),
        );

        now = now.add(const Duration(seconds: 10));
        await tracker.stop();

        expect(savedSceneId, 'scene-2');
        expect(savedResume, 42.0);
        expect(savedDuration, 10.0);

        tracker.dispose();
      },
    );
  });
}
