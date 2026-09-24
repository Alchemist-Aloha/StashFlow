import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/images/presentation/widgets/image_filter_panel.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  testWidgets('exposes all modeled image filter criteria', (tester) async {
    await pumpTestWidget(
      tester,
      child: const Scaffold(body: ImageFilterPanel()),
    );

    Future<void> expand(String label) async {
      final section = find.text(label);
      await tester.ensureVisible(section);
      await tester.tap(section);
      await tester.pumpAndSettle();
    }

    await expand('Metadata');
    expect(find.text('Date'), findsOneWidget);
    expect(find.text('Code'), findsOneWidget);
    expect(find.text('Photographer'), findsOneWidget);

    await expand('Library');
    expect(find.text('Tag Count'), findsOneWidget);
    expect(find.text('Folder'), findsOneWidget);

    await expand('Performer');
    expect(find.text('Performer Count'), findsOneWidget);
    expect(find.text('Performer Age'), findsOneWidget);
    expect(find.text('Favorites only'), findsOneWidget);

    await expand('System');
    expect(find.text('Checksum'), findsOneWidget);
    expect(find.text('Created At'), findsOneWidget);
    expect(find.text('Updated At'), findsOneWidget);

    await expand('Media Info');
    expect(find.text('pHash'), findsOneWidget);

    expect(find.text('Missing Field'), findsOneWidget);
    expect(find.text('Custom Fields'), findsOneWidget);
  });
}
