import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_app_flutter/core/data/repositories/graphql_saved_filter_repository.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
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
    final mockRepo = MockGraphQLGroupRepository()..withData([testGroup]);

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

  testWidgets(
    'GroupsPage sort panel matches the scene-list scrollable chip layout',
    (tester) async {
      final mockRepo = MockGraphQLGroupRepository()..withData([testGroup]);

      await pumpTestWidget(
        tester,
        prefs: prefs,
        overrides: [groupRepositoryProvider.overrideWithValue(mockRepo)],
        child: const GroupsPage(),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      expect(find.byType(Scrollbar), findsOneWidget);
    },
  );

  testWidgets('GroupsPage exposes saved preset dialog action', (tester) async {
    final mockRepo = MockGraphQLGroupRepository()..withData([testGroup]);
    final savedFilterRepository = GraphQLSavedFilterRepository(
      _FakeSavedFilterClient(),
    );

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [
        groupRepositoryProvider.overrideWithValue(mockRepo),
        savedFilterRepositoryProvider.overrideWithValue(savedFilterRepository),
      ],
      child: const GroupsPage(),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.bookmarks_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.bookmarks_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Saved Presets'), findsOneWidget);
  });

  testWidgets('GroupsPage opens group details within the groups shell route', (
    tester,
  ) async {
    final mockRepo = MockGraphQLGroupRepository()..withData([testGroup]);
    final router = GoRouter(
      initialLocation: '/groups',
      routes: [
        GoRoute(
          path: '/groups',
          builder: (context, state) => const GroupsPage(),
          routes: [
            GoRoute(
              path: 'group/:id',
              builder: (context, state) =>
                  Text('Group detail: ${state.pathParameters['id']}'),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          groupRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(testGroup.name));
    await tester.pumpAndSettle();

    expect(find.text('Group detail: ${testGroup.id}'), findsOneWidget);
  });
}

class _FakeSavedFilterClient extends GraphQLClient {
  _FakeSavedFilterClient()
    : super(
        cache: GraphQLCache(),
        link: Link.function((request, [forward]) => const Stream.empty()),
      );

  @override
  Future<QueryResult<TParsed>> query<TParsed>(
    QueryOptions<TParsed> options,
  ) async {
    return QueryResult<TParsed>(
      source: QueryResultSource.network,
      data: const {'findSavedFilters': []},
      options: options,
    );
  }

  @override
  Future<QueryResult<TParsed>> mutate<TParsed>(
    MutationOptions<TParsed> options,
  ) async {
    return QueryResult<TParsed>(
      source: QueryResultSource.network,
      data: const {'saveFilter': null},
      options: options,
    );
  }
}
