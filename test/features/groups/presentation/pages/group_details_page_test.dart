import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stash_app_flutter/core/presentation/widgets/related_entities.dart';
import 'package:stash_app_flutter/features/groups/domain/entities/group.dart';
import 'package:stash_app_flutter/features/groups/presentation/pages/group_details_page.dart';
import 'package:stash_app_flutter/features/groups/presentation/providers/group_details_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/entity_media_filter_scope.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
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
