import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stash_app_flutter/features/tags/domain/entities/tag.dart';
import 'package:stash_app_flutter/features/tags/presentation/pages/tags_page.dart';
import 'package:stash_app_flutter/features/tags/presentation/providers/tag_list_provider.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  const testTag = Tag(
    id: 't1',
    name: 'Test Tag',
    sceneCount: 10,
    imageCount: 0,
    galleryCount: 0,
    performerCount: 2,
    favorite: false,
  );

  testWidgets('TagsPage displays list of tags', (tester) async {
    final mockRepo = MockGraphQLTagRepository()..withData([testTag]);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [tagRepositoryProvider.overrideWithValue(mockRepo)],
      child: const TagsPage(),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('Test Tag'), findsOneWidget);
  });

  testWidgets('TagsPage sort panel uses the scene-list title layout', (
    tester,
  ) async {
    final mockRepo = MockGraphQLTagRepository()..withData([testTag]);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [tagRepositoryProvider.overrideWithValue(mockRepo)],
      child: const TagsPage(),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.sort));
    await tester.pumpAndSettle();

    expect(
      find.ancestor(
        of: find.text('Sort Tags'),
        matching: find.byType(Expanded),
      ),
      findsOneWidget,
    );
  });
}
