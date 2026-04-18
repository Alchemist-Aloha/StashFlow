import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stash_app_flutter/features/performers/domain/entities/performer.dart';
import 'package:stash_app_flutter/features/performers/presentation/pages/performers_page.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_list_provider.dart';
import 'package:stash_app_flutter/features/performers/presentation/widgets/performer_card.dart';

import 'package:stash_app_flutter/features/performers/domain/entities/performer_filter.dart' as domain;
import '../../helpers/test_helpers.dart';

class MockPerformerSort extends PerformerSort {
  @override
  ({String? sort, bool descending, int? randomSeed}) build() =>
      (sort: 'name', descending: false, randomSeed: null);
}

class MockPerformerSearchQuery extends PerformerSearchQuery {
  @override
  String build() => '';
}

class MockPerformerFilterState extends PerformerFilterState {
  @override
  domain.PerformerFilter build() => domain.PerformerFilter.empty();
}

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
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final mockRepo = MockPerformerRepository()
      ..withData([testPerformer, testPerformer2]);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [
        performerRepositoryProvider.overrideWithValue(mockRepo),
        performerSortProvider.overrideWith(MockPerformerSort.new),
        performerSearchQueryProvider.overrideWith(MockPerformerSearchQuery.new),
        performerFilterStateProvider.overrideWith(MockPerformerFilterState.new),
      ],
      child: const PerformersPage(),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(PerformerCard), findsNWidgets(2));
    expect(find.text('Test Performer'), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);
  });

  testWidgets('PerformersPage search filters list', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final mockRepo = MockPerformerRepository()
      ..withData([testPerformer, testPerformer2]);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [
        performerRepositoryProvider.overrideWithValue(mockRepo),
        performerSortProvider.overrideWith(MockPerformerSort.new),
        performerSearchQueryProvider.overrideWith(MockPerformerSearchQuery.new),
        performerFilterStateProvider.overrideWith(MockPerformerFilterState.new),
      ],
      child: const PerformersPage(),
    );
    await tester.pump(const Duration(seconds: 1));

    // Open search
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump(const Duration(seconds: 1));

    // Mock data update on search query change (normally repo handles filtering)
    mockRepo.withData([testPerformer2]);

    await tester.enterText(find.byType(TextField), 'Alice');
    // We might need multiple pumps if it's a debounced search,
    // but here it seems immediate in the provider.
    await tester.pump(const Duration(seconds: 1));

    expect(
      find.descendant(
        of: find.byType(PerformerCard),
        matching: find.text('Alice'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(PerformerCard),
        matching: find.text('Test Performer'),
      ),
      findsNothing,
    );
  });

  testWidgets('PerformersPage filters by favorites only', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final mockRepo = MockPerformerRepository()
      ..withData([testPerformer, testPerformer2]);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [
        performerRepositoryProvider.overrideWithValue(mockRepo),
        performerSortProvider.overrideWith(MockPerformerSort.new),
        performerSearchQueryProvider.overrideWith(MockPerformerSearchQuery.new),
        performerFilterStateProvider.overrideWith(MockPerformerFilterState.new),
      ],
      child: const PerformersPage(),
    );
    await tester.pump(const Duration(seconds: 1));

    // Open filter
    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pump(const Duration(seconds: 1));

    // Change mock to reflect filtered data
    mockRepo.withData([testPerformer2]);

    // Tap favorites only switch (scroll if needed)
    final switchFinder = find.byType(SwitchListTile);
    await tester.ensureVisible(switchFinder);
    await tester.tap(switchFinder, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 500));

    // Apply filter
    await tester.tap(find.text('Apply Filters'));
    await tester.pump(const Duration(seconds: 1));

    expect(
      find.descendant(
        of: find.byType(PerformerCard),
        matching: find.text('Alice'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(PerformerCard),
        matching: find.text('Test Performer'),
      ),
      findsNothing,
    );
  });
}
