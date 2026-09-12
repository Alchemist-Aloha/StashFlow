import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_filter_panel.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
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
    expect(find.text('Phash'), findsOneWidget);

    await expand('System');
    expect(find.text('Stash ID'), findsWidgets);
    expect(find.text('Custom Fields'), findsOneWidget);
    expect(find.text('Missing Field'), findsOneWidget);
  });
}
