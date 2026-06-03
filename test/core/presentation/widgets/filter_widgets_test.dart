import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';
import 'package:stash_app_flutter/core/presentation/widgets/filter_widgets.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('filter widgets', () {
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
