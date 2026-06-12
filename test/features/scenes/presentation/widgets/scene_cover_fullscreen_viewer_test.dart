import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_cover_fullscreen_viewer.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

void main() {
  Future<void> doubleTap(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(finder);
    await tester.pump(const Duration(milliseconds: 400));
  }

  Widget buildSubject({
    required TransformationController controller,
    bool asDialog = false,
  }) {
    final viewer = SceneCoverFullscreenViewer(
      imageUrl: 'https://example.com/cover.jpg',
      transformationController: controller,
      imageBuilder: (context, imageUrl) => const ColoredBox(color: Colors.blue),
    );

    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: asDialog
            ? Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).push(MaterialPageRoute<void>(builder: (_) => viewer));
                      },
                      child: const Text('Open'),
                    ),
                  ),
                ),
              )
            : viewer,
      ),
    );
  }

  testWidgets('viewer supports pinch zoom from 1x to 4x', (tester) async {
    final controller = TransformationController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(buildSubject(controller: controller));

    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    expect(viewer.minScale, 1);
    expect(viewer.maxScale, 4);
    expect(viewer.panEnabled, isTrue);
    expect(viewer.scaleEnabled, isTrue);
  });

  testWidgets('double tap enlarges and restores cover', (tester) async {
    final controller = TransformationController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(buildSubject(controller: controller));

    final surface = find.byKey(
      const Key('scene_cover_fullscreen_zoom_surface'),
    );
    await doubleTap(tester, surface);

    expect(controller.value.getMaxScaleOnAxis(), closeTo(2.5, 0.001));

    await doubleTap(tester, surface);

    expect(controller.value, equals(Matrix4.identity()));
  });

  testWidgets('exit button closes fullscreen viewer route', (tester) async {
    final controller = TransformationController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      buildSubject(controller: controller, asDialog: true),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('scene_cover_fullscreen_viewer')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const Key('scene_cover_fullscreen_exit_button')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('scene_cover_fullscreen_viewer')),
      findsNothing,
    );
    expect(find.text('Open'), findsOneWidget);
  });
}
