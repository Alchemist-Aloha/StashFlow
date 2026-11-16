import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stash_app_flutter/core/presentation/widgets/related_entities.dart';
import 'package:stash_app_flutter/core/presentation/widgets/section_panel.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/groups/domain/entities/group.dart';
import 'package:stash_app_flutter/features/groups/presentation/pages/group_details_page.dart';
import 'package:stash_app_flutter/features/groups/presentation/providers/group_details_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/entity_media_filter_scope.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('group detail spacing follows live UI scale ($brightness)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final scale = ValueNotifier(0.8);
      addTearDown(scale.dispose);
      const group = Group(
        id: 'scaled',
        name: 'A collection with a long name',
        duration: 3725,
        aliases: 'An alternate collection name',
        synopsis: 'Description of this collection',
        tags: [(id: 'tag', name: 'A tag with a long name')],
        subGroups: [
          GroupRelation(
            id: 'child',
            name: 'A related collection with a long name',
            description: 'A relationship description',
          ),
        ],
      );
      await pumpTestWidget(
        tester,
        overrides: [
          groupDetailsProvider(group.id).overrideWith((ref) => group),
          entityMediaPreviewProvider(
            EntityMediaFilterKind.group,
            group.id,
          ).overrideWith((ref) => []),
        ],
        child: ValueListenableBuilder<double>(
          valueListenable: scale,
          child: const GroupDetailsPage(groupId: 'scaled'),
          builder: (context, factor, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(1.3)),
            child: Theme(
              data: AppTheme.buildTheme(
                brightness,
                Colors.teal,
                fontSizeFactor: factor,
                useTrueBlack: true,
              ),
              child: child!,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      for (final factor in [0.8, 1.5]) {
        scale.value = factor;
        await tester.pumpAndSettle();
        expect(tester.getTopLeft(find.text(group.name)).dx, 16 * factor);
        final chips = tester.widget<Wrap>(
          find
              .ancestor(
                of: find.byIcon(Icons.timer_outlined),
                matching: find.byType(Wrap),
              )
              .first,
        );
        expect(chips.spacing, 8 * factor);
        expect(chips.runSpacing, 8 * factor);
        expect(
          tester.widget<Icon>(find.byIcon(Icons.timer_outlined)).size,
          16 * factor,
        );
        final panels = tester.widgetList<SectionPanel>(
          find.byType(SectionPanel),
        );
        expect(
          panels.map((panel) => panel.title),
          containsAll(['Tags', 'Synopsis', 'Sub-Groups']),
        );
        for (final panel in panels) {
          expect(panel.margin, EdgeInsets.only(bottom: 16 * factor));
        }
        expect(find.text('Description of this collection'), findsOneWidget);
        expect(find.text('A relationship description'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets('group details show studio, tags, aliases and related groups', (
    tester,
  ) async {
    const group = Group(
      id: '1',
      name: 'Shorts 01',
      aliases: 'LAS-01',
      duration: 3725,
      urls: ['https://example.org/shorts'],
      studioId: '2',
      studioName: 'Lantern Studio',
      tags: [(id: '3', name: 'Open Movie')],
      containingGroups: [
        GroupRelation(id: '9', name: 'Collection', description: 'Volume one'),
      ],
      subGroups: [GroupRelation(id: '4', name: 'Shorts 01 Extras')],
    );

    await pumpTestWidget(
      tester,
      overrides: [
        groupDetailsProvider('1').overrideWith((ref) => group),
        entityMediaPreviewProvider(
          EntityMediaFilterKind.group,
          '1',
        ).overrideWith((ref) => []),
      ],
      child: const GroupDetailsPage(groupId: '1'),
    );
    await tester.pumpAndSettle();

    expect(find.text('LAS-01'), findsOneWidget);
    expect(find.text('1:02:05'), findsOneWidget);
    expect(find.text('Open Movie'), findsOneWidget);
    expect(find.text('https://example.org/shorts'), findsOneWidget);
    expect(
      find.widgetWithText(RelatedEntityTile, 'Lantern Studio'),
      findsOneWidget,
    );
    expect(find.text('Containing Groups'), findsOneWidget);
    expect(find.text('Volume one'), findsOneWidget);
    expect(find.text('Sub-Groups'), findsOneWidget);
    expect(
      find.widgetWithText(RelatedEntityTile, 'Shorts 01 Extras'),
      findsOneWidget,
    );
    // No cover set: the placeholder icon stands in for the box art.
    expect(find.byIcon(Icons.group_work), findsWidgets);
  });
}
