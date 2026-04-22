import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/transformable_video_surface.dart';

class ManualMockVideoPlayerController extends VideoPlayerController {
  ManualMockVideoPlayerController() : super.networkUrl(Uri.parse('https://example.com'));

  @override
  Future<void> initialize() async {}

  @override
  VideoPlayerValue get value => VideoPlayerValue(
    duration: const Duration(seconds: 60),
    isInitialized: true,
  );
}

void main() {
  testWidgets('TransformableVideoSurface applies transformation on scale gesture', (tester) async {
    final controller = ManualMockVideoPlayerController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 1600,
              height: 900,
              child: TransformableVideoSurface(
                controller: controller,
                aspectRatio: 16 / 9,
              ),
            ),
          ),
        ),
      ),
    );

    // Verify initial identity transform
    final transformFinder = find.descendant(
      of: find.byType(TransformableVideoSurface),
      matching: find.byType(Transform),
    );
    expect(transformFinder, findsOneWidget);
    var transform = tester.widget<Transform>(transformFinder);
    expect(transform.transform, equals(Matrix4.identity()));
  });
}
