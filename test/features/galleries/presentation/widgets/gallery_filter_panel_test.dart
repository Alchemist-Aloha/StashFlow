import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/galleries/presentation/widgets/gallery_filter_panel.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  testWidgets('exposes all modeled gallery filter criteria', (tester) async {
    await pumpTestWidget(
      tester,
      child: const Scaffold(body: GalleryFilterPanel()),
    );

    Future<void> expand(String label) async {
      final section = find.text(label);
      await tester.ensureVisible(section);
      await tester.tap(section);
      await tester.pumpAndSettle();
    }

    await expand('Library');
    expect(find.text('Scenes'), findsOneWidget);
    expect(find.text('Folder'), findsOneWidget);

    await expand('Performer');
    expect(find.text('Favorites only'), findsOneWidget);

    await expand('Media Info');
    expect(find.text('Resolution'), findsOneWidget);

    await expand('Metadata');
    expect(find.text('Code'), findsOneWidget);
    expect(find.text('Photographer'), findsOneWidget);

    await expand('System');
    expect(find.text('Missing Field'), findsOneWidget);
    expect(find.text('Custom Fields'), findsOneWidget);
  });
}
