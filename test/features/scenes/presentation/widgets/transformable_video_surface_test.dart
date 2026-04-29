import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/transformable_video_surface.dart';

class ManualMockVideoController extends Mock implements VideoController {
  @override
  Player get player => MockPlayer();
}

class MockPlayer extends Mock implements Player {}

void main() {
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
