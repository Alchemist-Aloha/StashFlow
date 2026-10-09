import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stash_app_flutter/features/performers/domain/entities/performer.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_details_provider.dart';
import 'package:stash_app_flutter/features/tags/domain/entities/tag.dart';
import 'package:stash_app_flutter/features/tags/presentation/providers/tag_details_provider.dart';
import 'package:stash_app_flutter/features/studios/domain/entities/studio.dart';
import 'package:stash_app_flutter/features/studios/presentation/providers/studio_details_provider.dart';
import 'package:stash_app_flutter/features/groups/domain/entities/group.dart';
import 'package:stash_app_flutter/features/groups/presentation/providers/group_details_provider.dart';
import 'package:stash_app_flutter/features/galleries/domain/entities/gallery.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/gallery_details_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';
import 'package:stash_app_flutter/core/presentation/widgets/filter_widgets.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('filter widgets', () {
    final entityOverrides = {
      'performer': performerDetailsProvider('42').overrideWith(
        (ref) async => const Performer(
          id: '42',
          name: 'Alice',
          urls: [],
          birthdate: null,
          aliasList: [],
          favorite: false,
          imagePath: null,
          sceneCount: 0,
          imageCount: 0,
          galleryCount: 0,
          groupCount: 0,
          tagIds: [],
          tagNames: [],
        ),
      ),
      'tag': tagDetailsProvider('42').overrideWith(
        (ref) async => const Tag(
          id: '42',
          name: 'Portrait',
          sceneCount: 0,
          imageCount: 0,
          galleryCount: 0,
          performerCount: 0,
          favorite: false,
        ),
      ),
      'studio': studioDetailsProvider('42').overrideWith(
        (ref) async => const Studio(
          id: '42',
          name: 'Studio A',
          favorite: false,
          sceneCount: 0,
          imageCount: 0,
          galleryCount: 0,
          performerCount: 0,
        ),
      ),
      'group': groupDetailsProvider(
        '42',
      ).overrideWith((ref) async => const Group(id: '42', name: 'Collection')),
      'gallery': galleryDetailsProvider('42').overrideWith(
        (ref) async => const Gallery(
          id: '42',
          title: '',
          path: '/photos/Holiday_album.zip',
        ),
      ),
    };
    final names = {
      'performer': 'Alice',
      'tag': 'Portrait',
      'studio': 'Studio A',
      'group': 'Collection',
      'gallery': 'Holiday album',
    };

    for (final type in entityOverrides.keys) {
      testWidgets('selected $type uses its name but removes by ID', (
        tester,
      ) async {
        String? removedId;
        await pumpTestWidget(
          tester,
          overrides: [entityOverrides[type]!],
          child: Scaffold(
            body: SelectionCriterionInput(
              label: type,
              providerType: type,
              selectedIds: const ['42'],
              modifier: CriterionModifier.includes,
              onModifierChanged: (_) {},
              onAddPressed: () {},
              onRemoveId: (id) => removedId = id,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text(names[type]!), findsOneWidget);
        expect(find.text('42'), findsNothing);
        tester.widget<Chip>(find.byType(Chip)).onDeleted!();
        expect(removedId, '42');
      });
    }

    testWidgets('unavailable entity keeps a removable ID fallback', (
      tester,
    ) async {
      final pending = Completer<Tag>();
      String? removedId;
      await pumpTestWidget(
        tester,
        overrides: [
          tagDetailsProvider('42').overrideWith((ref) => pending.future),
        ],
        child: Scaffold(
          body: SelectionCriterionInput(
            label: 'Performer tags',
            providerType: 'tag',
            selectedIds: const ['42'],
            modifier: CriterionModifier.includes,
            onModifierChanged: (_) {},
            onAddPressed: () {},
            onRemoveId: (id) => removedId = id,
          ),
        ),
      );
      expect(find.text('42'), findsOneWidget);
      pending.completeError(StateError('Entity unavailable'));
      await tester.pumpAndSettle();
      expect(find.text('42'), findsOneWidget);
      tester.widget<Chip>(find.byType(Chip)).onDeleted!();
      expect(removedId, '42');
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'StringCriterionInput exposes regex operators and hides the value field for null modifiers',
      (tester) async {
        StringCriterion? criterion = const StringCriterion(value: 'scene');

        await pumpTestWidget(
          tester,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: StringCriterionInput(
                  label: 'Title',
                  value: criterion,
                  onChanged: (next) => setState(() => criterion = next),
                ),
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Equals'));
        await tester.pumpAndSettle();

        expect(find.text('Matches Regex'), findsOneWidget);
        expect(find.text('Does Not Match Regex'), findsOneWidget);

        await tester.tap(find.text('Matches Regex').last);
        await tester.pumpAndSettle();

        expect(criterion?.modifier, CriterionModifier.matchesRegex);
        expect(find.byType(TextFormField), findsOneWidget);

        await tester.tap(find.text('Matches Regex'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Is Null').last);
        await tester.pumpAndSettle();

        expect(criterion?.modifier, CriterionModifier.isNull);
        expect(find.byType(TextFormField), findsNothing);
      },
    );

    testWidgets(
      'IntCriterionInput shows a second value field for between operators',
      (tester) async {
        IntCriterion? criterion = const IntCriterion(value: 10);

        await pumpTestWidget(
          tester,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: IntCriterionInput(
                  label: 'Rating',
                  value: criterion,
                  onChanged: (next) => setState(() => criterion = next),
                ),
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Equals'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Between').last);
        await tester.pumpAndSettle();

        expect(criterion?.modifier, CriterionModifier.between);
        expect(find.byType(TextFormField), findsNWidgets(2));

        await tester.enterText(find.byType(TextFormField).first, '10');
        await tester.enterText(find.byType(TextFormField).last, '20');
        await tester.pump();

        expect(criterion?.value, 10);
        expect(criterion?.value2, 20);
      },
    );

    testWidgets(
      'IntCriterionInput keeps focus while typing into a between field',
      (tester) async {
        IntCriterion? criterion = const IntCriterion(value: 10);

        await pumpTestWidget(
          tester,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: IntCriterionInput(
                  label: 'Rating',
                  value: criterion,
                  onChanged: (next) => setState(() => criterion = next),
                ),
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Equals'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Between').last);
        await tester.pumpAndSettle();

        final firstField = find.byType(TextFormField).first;
        await tester.tap(firstField);
        await tester.pump();

        expect(
          tester
              .widget<EditableText>(find.byType(EditableText).first)
              .focusNode
              .hasFocus,
          isTrue,
        );

        await tester.enterText(firstField, '1');
        await tester.pump();

        expect(
          tester
              .widget<EditableText>(find.byType(EditableText).first)
              .focusNode
              .hasFocus,
          isTrue,
        );
      },
    );

    testWidgets(
      'DateCriterionInput shows a second value field for between operators',
      (tester) async {
        DateCriterion? criterion = const DateCriterion(value: '2024-01-01');

        await pumpTestWidget(
          tester,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: DateCriterionInput(
                  label: 'Date',
                  value: criterion,
                  onChanged: (next) => setState(() => criterion = next),
                ),
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Equals'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Between').last);
        await tester.pumpAndSettle();

        expect(criterion?.modifier, CriterionModifier.between);
        expect(find.byType(TextFormField), findsNWidgets(2));

        await tester.enterText(find.byType(TextFormField).first, '2024-01-01');
        await tester.enterText(find.byType(TextFormField).last, '2024-12-31');
        await tester.pump();

        expect(criterion?.value, '2024-01-01');
        expect(criterion?.value2, '2024-12-31');
      },
    );
  });
}
