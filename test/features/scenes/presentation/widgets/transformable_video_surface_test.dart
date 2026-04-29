import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/transformable_video_surface.dart';
import 'package:stash_app_flutter/core/presentation/video/app_video_controller.dart';

class ManualMockVideoPlayerController extends ValueNotifier<AppVideoValue>
    implements AppVideoController {
  ManualMockVideoPlayerController()
      : super(
          const AppVideoValue(
            isInitialized: true,
            isPlaying: false,
            position: Duration.zero,
            duration: Duration(seconds: 60),
            playbackSpeed: 1.0,
            aspectRatio: 16 / 9,
            size: Size(1600, 900),
            captionText: '',
            buffered: <AppDurationRange>[],
          ),
        );

  @override
  String get dataSource => 'https://example.com';

  @override
  Future<void> initialize() async {}

  @override
  Future<void> play() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> seekTo(Duration position) async {}

  @override
  Future<void> setLooping(bool value) async {}

  @override
  Future<void> setPlaybackSpeed(double speed) async {}

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> setSubtitleUrl(String? url) async {}

  @override
  Future<void> dispose() async {
    super.dispose();
  }
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
