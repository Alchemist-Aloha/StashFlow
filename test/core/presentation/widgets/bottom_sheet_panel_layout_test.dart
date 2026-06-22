import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/presentation/widgets/filter_bottom_sheet_scaffold.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  testWidgets('filter panel scaffold uses the shared panel layout contract', (
    tester,
  ) async {
    await pumpTestWidget(
      tester,
      child: Scaffold(
        body: SizedBox(
          height: 420,
          child: FilterBottomSheetScaffold(
            title: 'Filter Title',
            onReset: () {},
            body: const SizedBox.shrink(),
            onApply: () {},
            onSaveDefault: () async {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final filterTitle = find.text('Filter Title');

    final filterHeaderPadding = tester.widget<Padding>(
      find.ancestor(of: filterTitle, matching: find.byType(Padding)).first,
    );
    expect(
      filterHeaderPadding.padding,
      const EdgeInsets.all(AppTheme.spacingLarge),
    );

    final filterText = tester.widget<Text>(filterTitle);
    expect(
      filterText.style?.fontSize,
      greaterThan(AppTheme.lightTheme.textTheme.titleLarge?.fontSize ?? 0),
    );

    expect(
      find.ancestor(of: filterTitle, matching: find.byType(Expanded)),
      findsOneWidget,
    );
  });
}
