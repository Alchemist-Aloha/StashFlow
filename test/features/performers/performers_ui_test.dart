import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stash_app_flutter/features/performers/domain/entities/performer.dart';
import 'package:stash_app_flutter/features/performers/presentation/pages/performers_page.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_list_provider.dart';
import 'package:stash_app_flutter/features/performers/presentation/widgets/performer_card.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  const testPerformer = Performer(
    id: 'p1',
    name: 'Test Performer',
    disambiguation: 'D',
    urls: [],
    gender: 'FEMALE',
    birthdate: '1990-01-01',
    aliasList: [],
    favorite: false,
    imagePath: 'path/to/image',
    sceneCount: 10,
    imageCount: 0,
    galleryCount: 0,
    groupCount: 0,
    tagIds: [],
    tagNames: [],
  );

  const testPerformer2 = Performer(
    id: 'p2',
    name: 'Alice',
    disambiguation: null,
    urls: [],
    gender: 'FEMALE',
    birthdate: null,
    aliasList: [],
    favorite: true,
    imagePath: null,
    sceneCount: 5,
    imageCount: 0,
    galleryCount: 0,
    groupCount: 0,
    tagIds: [],
    tagNames: [],
  );

  testWidgets('PerformersPage displays list of performers', (tester) async {
    final mockRepo = MockPerformerRepository()..withData([testPerformer, testPerformer2]);
    
    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [performerRepositoryProvider.overrideWithValue(mockRepo)],
      child: const PerformersPage(),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PerformerCard), findsNWidgets(2));
    expect(find.text('Test Performer'), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);
  });

  testWidgets('PerformersPage search filters list', (tester) async {
    final mockRepo = MockPerformerRepository()..withData([testPerformer, testPerformer2]);
    
    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [performerRepositoryProvider.overrideWithValue(mockRepo)],
      child: const PerformersPage(),
    );
    await tester.pumpAndSettle();

    // Open search
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    // Mock data update on search query change (normally repo handles filtering)
    mockRepo.withData([testPerformer2]);

    await tester.enterText(find.byType(TextField), 'Alice');
    await tester.pumpAndSettle();

    expect(find.descendant(of: find.byType(PerformerCard), matching: find.text('Alice')), findsOneWidget);
    expect(find.descendant(of: find.byType(PerformerCard), matching: find.text('Test Performer')), findsNothing);
  });

  testWidgets('PerformersPage filters by favorites only', (tester) async {
    final mockRepo = MockPerformerRepository()..withData([testPerformer, testPerformer2]);
    
    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [performerRepositoryProvider.overrideWithValue(mockRepo)],
      child: const PerformersPage(),
    );
    await tester.pumpAndSettle();

    // Open filter
    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();

    // Change mock to reflect filtered data
    mockRepo.withData([testPerformer2]);

    // Tap favorites only switch
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    
    // Apply filter
    await tester.tap(find.text('Apply Filters'));
    await tester.pumpAndSettle();

    expect(find.descendant(of: find.byType(PerformerCard), matching: find.text('Alice')), findsOneWidget);
    expect(find.descendant(of: find.byType(PerformerCard), matching: find.text('Test Performer')), findsNothing);
  });
}
