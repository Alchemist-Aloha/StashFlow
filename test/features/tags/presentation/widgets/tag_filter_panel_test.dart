import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/tags/presentation/widgets/tag_filter_panel.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  testWidgets('exposes official tag filter groups', (tester) async {
    await pumpTestWidget(tester, child: const Scaffold(body: TagFilterPanel()));

    Future<void> expand(String label) async {
      final section = find.widgetWithText(ExpansionTile, label);
      await tester.ensureVisible(section);
      await tester.tap(section);
      await tester.pumpAndSettle();
    }

    expect(find.text('Favorite'), findsOneWidget);
    expect(find.text('Ignore auto tag'), findsOneWidget);

    await expand('Metadata');
    expect(find.text('Sort Name'), findsOneWidget);
    expect(find.text('Aliases'), findsOneWidget);

    await expand('Library');
    expect(find.text('Parent Tags'), findsOneWidget);
    expect(find.text('Sub-Tags'), findsOneWidget);

    await expand('Usage');
    expect(find.text('Studio Count'), findsOneWidget);
    expect(find.text('Parent Tag Count'), findsOneWidget);

    await expand('System');
    expect(find.text('Created At'), findsOneWidget);
    expect(find.text('Updated At'), findsOneWidget);
  });
}
