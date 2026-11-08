import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/local_captions_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:media_kit/media_kit.dart' as mk;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/transformable_video_surface.dart';

class _NoCaptions extends LocalCaptionsNotifier {
  @override
  LocalCaptions build() => const LocalCaptions();
}

class _CaptionTestApp extends StatelessWidget {
  const _CaptionTestApp({required this.home});
  final Widget home;
  @override
  Widget build(BuildContext context) => ProviderScope(
    overrides: [localCaptionsProvider.overrideWith(_NoCaptions.new)],
    child: MaterialApp(home: home),
  );
}

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

  Stream<List<mk.AudioTrack>> get audioTracks => const Stream.empty();

  Stream<List<mk.VideoTrack>> get videoTracks => const Stream.empty();

  Stream<List<mk.SubtitleTrack>> get subtitleTracks => const Stream.empty();

  Stream<mk.AudioTrack> get audioTrack => const Stream.empty();

  Stream<mk.VideoTrack> get videoTrack => const Stream.empty();

  Stream<mk.SubtitleTrack> get subtitleTrack => const Stream.empty();

  @override
  Stream<List<String>> get subtitle => const Stream.empty();
}

void main() {
  setUpAll(() {
    mk.MediaKit.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('wide video fits inline width with vertical letterboxing', (
    tester,
  ) async {
    await tester.pumpWidget(
      _CaptionTestApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              height: 225,
              child: TransformableVideoSurface(
                controller: ManualMockVideoController(),
                aspectRatio: 2560 / 1080,
                fontSize: 16,
                bottomRatio: 0.1,
                constraints: const BoxConstraints.tightFor(
                  width: 400,
                  height: 225,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final player = tester.getRect(find.byType(TransformableVideoSurface));
    final video = tester.getRect(find.byType(Video));
    expect(video.width, player.width);
    expect(video.height, closeTo(400 * 1080 / 2560, 0.001));
    expect(video.center, player.center);
    expect(video.top, greaterThan(player.top));
    expect(video.bottom, lessThan(player.bottom));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'TransformableVideoSurface applies transformation on scale gesture',
    (tester) async {
      final controller = ManualMockVideoController();

      await tester.pumpWidget(
        _CaptionTestApp(
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
      final transform = tester.widget<Transform>(transformFinder);
      expect(transform.transform, equals(Matrix4.identity()));
    },
  );
}
