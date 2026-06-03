import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql/client.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/graphql_scene_saved_filter_repository.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_filter.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_saved_filter_dialog.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

void main() {
  testWidgets(
    'opens a naming dialog from the header before saving the current preset',
    (tester) async {
      final client = _FakeGraphQLClient(
        queryData: {
          '__typename': 'Query',
          'findSavedFilters': <Map<String, dynamic>>[],
        },
        mutationData: {
          '__typename': 'Mutation',
          'saveFilter': {
            '__typename': 'SavedFilter',
            'id': '9',
            'mode': 'SCENES',
            'name': 'Favorites',
            'find_filter': {
              '__typename': 'SavedFindFilterType',
              'q': 'clip',
              'page': 1,
              'per_page': null,
              'sort': 'rating',
              'direction': 'DESC',
            },
            'object_filter': '{}',
            'ui_options': '{}',
          },
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sceneSavedFilterRepositoryProvider.overrideWithValue(
              GraphQLSceneSavedFilterRepository(client),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) => Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => SceneSavedFilterDialog(
                          searchQuery: 'clip',
                          sort: 'rating',
                          descending: true,
                          filter: SceneFilter.empty(),
                          onLoad: (_) {},
                        ),
                      );
                    },
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Current Settings'), findsOneWidget);
      expect(find.text('Available Presets'), findsOneWidget);

      final dialogSize = tester.getSize(find.byType(SceneSavedFilterDialog));
      final screenHeight =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      expect(dialogSize.height, lessThan(screenHeight * 0.8));

      expect(find.text('Preset name'), findsNothing);

      await tester.tap(find.byIcon(Icons.save_outlined).first);
      await tester.pumpAndSettle();

      expect(find.text('Save Preset'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Preset name'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Preset name'),
        'Favorites',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      final input =
          client.lastMutationVariables!['input'] as Map<String, dynamic>;
      expect(input['name'], 'Favorites');
      expect(input['find_filter']['q'], 'clip');
      expect(input['find_filter']['sort'], 'rating');
      expect(input['find_filter']['direction'], 'DESC');
      expect(find.text('Scene filter saved to server'), findsOneWidget);
    },
  );

  testWidgets(
    'confirms before deleting a saved preset and removes it after confirmation',
    (tester) async {
      final client = _FakeGraphQLClient(
        queryResponses: [
          {
            '__typename': 'Query',
            'findSavedFilters': [
              {
                '__typename': 'SavedFilter',
                'id': '9',
                'mode': 'SCENES',
                'name': 'Favorites',
                'find_filter': {
                  '__typename': 'SavedFindFilterType',
                  'q': 'clip',
                  'page': 1,
                  'per_page': null,
                  'sort': 'rating',
                  'direction': 'DESC',
                },
                'object_filter': '{}',
                'ui_options': '{}',
              },
            ],
          },
          {'__typename': 'Query', 'findSavedFilters': <Map<String, dynamic>>[]},
        ],
        deleteMutationData: {
          '__typename': 'Mutation',
          'destroySavedFilter': true,
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sceneSavedFilterRepositoryProvider.overrideWithValue(
              GraphQLSceneSavedFilterRepository(client),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) => Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => SceneSavedFilterDialog(
                          searchQuery: 'clip',
                          sort: 'rating',
                          descending: true,
                          filter: SceneFilter.empty(),
                          onLoad: (_) {},
                        ),
                      );
                    },
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Favorites'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Delete Preset'), findsOneWidget);
      expect(
        find.text('Delete "Favorites"? This action cannot be undone.'),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(client.lastDeleteVariables, isNull);
      expect(find.text('Favorites'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(client.lastDeleteVariables, {
        'input': {'id': '9'},
      });
      expect(find.text('Favorites'), findsNothing);
      expect(find.text('Preset deleted'), findsOneWidget);
    },
  );
}

class _FakeGraphQLClient extends GraphQLClient {
  _FakeGraphQLClient({
    this.queryData,
    this.queryResponses,
    this.mutationData,
    this.deleteMutationData,
  }) : super(
         cache: GraphQLCache(),
         link: Link.function((request, [forward]) => const Stream.empty()),
       );

  final Map<String, dynamic>? queryData;
  final List<Map<String, dynamic>>? queryResponses;
  final Map<String, dynamic>? mutationData;
  final Map<String, dynamic>? deleteMutationData;
  Map<String, dynamic>? lastMutationVariables;
  Map<String, dynamic>? lastDeleteVariables;
  int _queryIndex = 0;

  @override
  Future<QueryResult<TParsed>> query<TParsed>(
    QueryOptions<TParsed> options,
  ) async {
    final response =
        queryResponses != null &&
            queryResponses!.isNotEmpty &&
            _queryIndex < queryResponses!.length
        ? queryResponses![_queryIndex++]
        : queryData;
    return QueryResult<TParsed>(
      source: QueryResultSource.network,
      data: response,
      options: options,
    );
  }

  @override
  Future<QueryResult<TParsed>> mutate<TParsed>(
    MutationOptions<TParsed> options,
  ) async {
    final input = options.variables['input'];
    if (input is Map && input.containsKey('name')) {
      lastMutationVariables = options.variables;
    } else {
      lastDeleteVariables = options.variables;
    }
    return QueryResult<TParsed>(
      source: QueryResultSource.network,
      data: input is Map && input.containsKey('name')
          ? mutationData
          : deleteMutationData,
      options: options,
    );
  }
}
