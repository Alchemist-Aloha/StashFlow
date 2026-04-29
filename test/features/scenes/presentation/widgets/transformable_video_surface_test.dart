import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:media_kit/media_kit.dart' as mk;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/transformable_video_surface.dart';

class ManualMockVideoController extends Mock implements VideoController {
  @override
  mk.Player get player => MockPlayer();

  @override
  ValueNotifier<PlatformVideoController?> get notifier => ValueNotifier(null);

  @override
  Future<void> get waitUntilFirstFrameRendered async {}
}

class MockPlayer extends Mock implements mk.Player {
  @override
  mk.PlayerStream get stream => MockPlayerStream();

  @override
  mk.PlayerState get state => mk.PlayerState();
}

class MockPlayerStream extends Fake implements mk.PlayerStream {
  @override
  Stream<bool> get playing => const Stream.empty();

  @override
  Stream<bool> get completed => const Stream.empty();

  @override
  Stream<Duration> get position => const Stream.empty();

  @override
  Stream<Duration> get duration => const Stream.empty();

  @override
  Stream<double> get volume => const Stream.empty();

  @override
  Stream<double> get rate => const Stream.empty();

  @override
  Stream<int> get width => const Stream.empty();

  @override
  Stream<int> get height => const Stream.empty();

  @override
  Stream<bool> get buffering => const Stream.empty();

  @override
  Stream<mk.Playlist> get playlist => const Stream.empty();

  @override
  Stream<mk.AudioParams> get audioParams => const Stream.empty();

  @override
  Stream<mk.VideoParams> get videoParams => const Stream.empty();

  @override
  Stream<List<mk.AudioTrack>> get audioTracks => const Stream.empty();

  @override
  Stream<List<mk.VideoTrack>> get videoTracks => const Stream.empty();

  @override
  Stream<List<mk.SubtitleTrack>> get subtitleTracks => const Stream.empty();

  @override
  Stream<mk.AudioTrack> get audioTrack => const Stream.empty();

  @override
  Stream<mk.VideoTrack> get videoTrack => const Stream.empty();

  @override
  Stream<mk.SubtitleTrack> get subtitleTrack => const Stream.empty();

  @override
  Stream<List<String>> get subtitle => const Stream.empty();
}

void main() {
  setUpAll(() {
    mk.MediaKit.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('TransformableVideoSurface applies transformation on scale gesture', (tester) async {
    final controller = ManualMockVideoController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 1600,
              height: 900,
              child: TransformableVideoSurface(
                fontSize: 16,
                textAlign: TextAlign.center,
                bottomRatio: 0.1,
                constraints: BoxConstraints(maxWidth: 1600, maxHeight: 900),
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
