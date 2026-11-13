import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stash_app_flutter/features/navigation/presentation/router.dart';
import 'package:stash_app_flutter/features/performers/presentation/pages/performer_details_page.dart';
import 'package:stash_app_flutter/features/scenes/presentation/pages/scene_details_page.dart';
import 'package:stash_app_flutter/features/studios/presentation/pages/studio_details_page.dart';

void main() {
  for (final extra in [null, true, 'unexpected payload']) {
    testWidgets('edit routes tolerate unavailable entity extras: $extra', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final router = container.listen(routerProvider, (_, _) {}).read();
      // Exercise the production route builders without starting media/network UI.
      await tester.pumpWidget(const SizedBox());
      final context = tester.element(find.byType(SizedBox));
      for (final (path, pageType) in [
        ('/scenes/scene/s1/edit', SceneDetailsPage),
        ('/performers/performer/p1/edit', PerformerDetailsPage),
        ('/studios/studio/s1/edit', StudioDetailsPage),
      ]) {
        final matches = router.configuration.findMatch(
          Uri.parse(path),
          extra: extra,
        );
        final match = matches.last;
        expect(matches.isError, isFalse);
        final state = match.buildState(
          router.configuration,
          matches,
          metadata: const {},
        );
        final page = match.route.builder!(context, state);
        expect(page.runtimeType, pageType);
      }
    });
  }

  test('disposing the provider disposes its router', () {
    final container = ProviderContainer();
    final router = container.read(routerProvider);
    container.dispose();
    expect(router.refresh, throwsFlutterError);
  });
}
