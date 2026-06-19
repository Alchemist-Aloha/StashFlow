import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/features/groups/domain/entities/group.dart';
import 'package:stash_app_flutter/features/groups/presentation/pages/groups_page.dart';
import 'package:stash_app_flutter/features/groups/presentation/providers/group_list_provider.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  const testGroup = Group(
    id: 'g1',
    name: 'Test Group',
    date: '2024-01-01',
    rating100: 80,
    director: 'Director',
    synopsis: 'Synopsis',
  );

  testWidgets('GroupsPage exposes sort and filter actions', (tester) async {
    final mockRepo = MockGroupRepository()..withData([testGroup]);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [groupRepositoryProvider.overrideWithValue(mockRepo)],
      child: const GroupsPage(),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.sort), findsOneWidget);
    expect(find.byIcon(Icons.filter_list), findsOneWidget);

    await tester.tap(find.byIcon(Icons.sort));
    await tester.pumpAndSettle();
    expect(find.text('Sort'), findsWidgets);
  });
}
