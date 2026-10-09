import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_filter_panel.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';
import 'package:stash_app_flutter/core/presentation/widgets/filter_widgets.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_filter.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_details_provider.dart';
import 'package:stash_app_flutter/features/tags/presentation/providers/tag_details_provider.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  testWidgets('restores typed multi and hierarchical entity criteria', (
    tester,
  ) async {
    await pumpTestWidget(
      tester,
      overrides: [
        performerDetailsProvider(
          '42',
        ).overrideWith((ref) async => throw StateError('Unavailable')),
        tagDetailsProvider(
          '77',
        ).overrideWith((ref) async => throw StateError('Unavailable')),
      ],
      child: const Scaffold(
        body: SceneFilterPanel(
          initialFilter: SceneFilter(
            performers: MultiCriterion(
              value: ['42'],
              modifier: CriterionModifier.excludes,
            ),
            performerTags: HierarchicalMultiCriterion(
              value: ['77'],
              modifier: CriterionModifier.includesAll,
              depth: 2,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Performer'));
    await tester.tap(find.text('Performer'));
    await tester.pumpAndSettle();

    final inputs = tester.widgetList<SelectionCriterionInput>(
      find.byType(SelectionCriterionInput),
    );
    final performers = inputs.singleWhere(
      (input) => input.label == 'Performers',
    );
    final tags = inputs.singleWhere((input) => input.label == 'Performer Tags');
    expect(performers.selectedIds, ['42']);
    expect(performers.modifier, CriterionModifier.excludes);
    expect(tags.selectedIds, ['77']);
    expect(tags.modifier, CriterionModifier.includesAll);
    expect(tester.takeException(), isNull);
  });

  testWidgets('exposes current official Stash scene criteria', (tester) async {
    await pumpTestWidget(
      tester,
      child: const Scaffold(body: SceneFilterPanel()),
    );

    Future<void> expand(String label) async {
      final section = find.text(label);
      await tester.ensureVisible(section);
      await tester.tap(section);
      await tester.pumpAndSettle();
    }

    expect(find.text('Title'), findsOneWidget);

    await expand('Metadata');
    expect(find.text('Production Date'), findsOneWidget);

    await expand('Performer');
    expect(find.text('Favorite'), findsOneWidget);

    await expand('Library');
    expect(find.text('Folder'), findsOneWidget);

    await expand('Media Info');
    expect(find.text('pHash'), findsOneWidget);

    await expand('System');
    expect(find.text('Stash ID'), findsWidgets);
    expect(find.text('Custom Fields'), findsOneWidget);
    expect(find.text('Missing Field'), findsOneWidget);
  });
}
