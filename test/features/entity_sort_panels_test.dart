import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/groups/presentation/pages/groups_page.dart';
import 'package:stash_app_flutter/features/groups/presentation/providers/group_list_provider.dart';
import 'package:stash_app_flutter/features/performers/presentation/pages/performers_page.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_list_provider.dart';
import 'package:stash_app_flutter/features/studios/presentation/pages/studios_page.dart';
import 'package:stash_app_flutter/features/studios/presentation/providers/studio_list_provider.dart';
import 'package:stash_app_flutter/features/tags/presentation/pages/tags_page.dart';
import 'package:stash_app_flutter/features/tags/presentation/providers/tag_list_provider.dart';

import '../helpers/test_helpers.dart';

void main() {
  for (final entry in [
    (page: const PerformersPage(), common: 7, total: 23, advanced: 'Birthdate'),
    (page: const StudiosPage(), common: 6, total: 18, advanced: 'Tag Count'),
    (page: const TagsPage(), common: 6, total: 13, advanced: 'Created At'),
    (page: const GroupsPage(), common: 7, total: 12, advanced: 'Tag Count'),
  ]) {
    testWidgets(
      '${entry.page.runtimeType} exposes and applies advanced sorting',
      (tester) async {
        await pumpTestWidget(
          tester,
          overrides: [
            performerRepositoryProvider.overrideWithValue(
              MockGraphQLPerformerRepository(),
            ),
            studioRepositoryProvider.overrideWithValue(
              MockGraphQLStudioRepository(),
            ),
            tagRepositoryProvider.overrideWithValue(MockGraphQLTagRepository()),
            groupRepositoryProvider.overrideWithValue(
              MockGraphQLGroupRepository(),
            ),
          ],
          child: entry.page,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.sort));
        await tester.pumpAndSettle();
        expect(find.byType(ChoiceChip), findsNWidgets(entry.common));
        expect(find.text(entry.advanced), findsNothing);
        await tester.ensureVisible(find.byType(ExpansionTile));
        await tester.tap(find.text('Advanced sort options'));
        await tester.pumpAndSettle();
        expect(find.byType(ChoiceChip), findsNWidgets(entry.total));
        final advanced = find.widgetWithText(ChoiceChip, entry.advanced);
        await tester.ensureVisible(advanced);
        await tester.tap(advanced);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Apply Sort'));
        await tester.pumpAndSettle();
        final container = ProviderScope.containerOf(
          tester.element(find.byType(entry.page.runtimeType)),
        );
        final sort = switch (entry.page) {
          PerformersPage() => container.read(performerSortProvider).sort,
          StudiosPage() => container.read(studioSortProvider).sort,
          TagsPage() => container.read(tagSortProvider).sort,
          _ => container.read(groupSortProvider).sort,
        };
        expect(sort, switch (entry.advanced) {
          'Birthdate' => 'birthdate',
          'Created At' => 'created_at',
          _ => 'tag_count',
        });
        await tester.tap(find.byIcon(Icons.sort));
        await tester.pumpAndSettle();
        expect(tester.widget<ChoiceChip>(advanced).selected, isTrue);
        expect(find.byType(ChoiceChip), findsNWidgets(entry.common + 1));
      },
    );
  }
}
