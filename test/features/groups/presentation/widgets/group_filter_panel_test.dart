import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/groups/presentation/widgets/group_filter_panel.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  testWidgets('exposes official group filter groups', (tester) async {
    await pumpTestWidget(
      tester,
      child: const Scaffold(body: GroupFilterPanel()),
    );

    Future<void> expand(String label) async {
      final section = find.widgetWithText(ExpansionTile, label);
      await tester.ensureVisible(section);
      await tester.tap(section);
      await tester.pumpAndSettle();
    }

    expect(find.text('Missing Field'), findsOneWidget);
    expect(find.text('Rating'), findsOneWidget);

    await expand('Metadata');
    expect(find.text('Director'), findsOneWidget);
    expect(find.text('Synopsis'), findsOneWidget);

    await expand('Library');
    expect(find.text('Studios'), findsOneWidget);
    expect(find.text('Performers'), findsOneWidget);

    await expand('Groups');
    expect(find.text('Containing Groups'), findsOneWidget);
    expect(find.text('Sub-Groups'), findsOneWidget);

    await expand('Usage');
    expect(find.text('Containing Group Count'), findsOneWidget);
    expect(find.text('Sub-group Count'), findsOneWidget);

    await expand('System');
    expect(find.text('Created At'), findsOneWidget);
    expect(find.text('Updated At'), findsOneWidget);
  });
}
