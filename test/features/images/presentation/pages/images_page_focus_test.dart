import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_app_flutter/features/images/domain/entities/image.dart'
    as entity;
import 'package:stash_app_flutter/features/images/presentation/pages/images_page.dart';
import 'package:stash_app_flutter/features/images/presentation/providers/image_list_provider.dart';
import 'package:stash_app_flutter/features/images/presentation/widgets/image_card.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  testWidgets('returning from fullscreen focuses the viewed image card', (
    tester,
  ) async {
    final repository = MockGraphQLImageRepository()
      ..withData(
        List.generate(
          40,
          (index) => entity.Image(
            id: 'image-$index',
            title: 'Image $index',
            files: const [entity.ImageFile(width: 100, height: 100, path: '')],
            paths: const entity.ImagePaths(image: '', thumbnail: ''),
          ),
        ),
      );

    await pumpTestWidget(
      tester,
      overrides: [imageRepositoryProvider.overrideWithValue(repository)],
      child: const ImagesPage(),
      routes: [
        GoRoute(
          path: '/galleries/images/:id',
          builder: (context, state) => Consumer(
            builder: (context, ref, child) => Scaffold(
              body: Center(
                child: FilledButton(
                  key: const Key('close_viewer_on_image_20'),
                  onPressed: () {
                    ref
                        .read(imageFullscreenCurrentIdProvider.notifier)
                        .setCurrent('image-20');
                    context.pop();
                  },
                  child: const Text('Close viewer'),
                ),
              ),
            ),
          ),
        ),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ImageCard).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('close_viewer_on_image_20')));
    await tester.pumpAndSettle();

    final focusedCard = find.byWidgetPredicate(
      (widget) => widget is ImageCard && widget.image.id == 'image-20',
    );
    expect(focusedCard, findsOneWidget);

    final inkWell = tester.widget<InkWell>(
      find.descendant(of: focusedCard, matching: find.byType(InkWell)),
    );
    expect(inkWell.focusNode?.hasFocus, isTrue);
    expect(
      Scrollable.of(tester.element(focusedCard)).position.pixels,
      greaterThan(0),
    );
  });
}
