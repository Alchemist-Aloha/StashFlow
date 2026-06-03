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
}

class _FakeGraphQLClient extends GraphQLClient {
  _FakeGraphQLClient({this.queryData, this.mutationData})
    : super(
        cache: GraphQLCache(),
        link: Link.function((request, [forward]) => const Stream.empty()),
      );

  final Map<String, dynamic>? queryData;
  final Map<String, dynamic>? mutationData;
  Map<String, dynamic>? lastMutationVariables;

  @override
  Future<QueryResult<TParsed>> query<TParsed>(
    QueryOptions<TParsed> options,
  ) async {
    return QueryResult<TParsed>(
      source: QueryResultSource.network,
      data: queryData,
      options: options,
    );
  }

  @override
  Future<QueryResult<TParsed>> mutate<TParsed>(
    MutationOptions<TParsed> options,
  ) async {
    lastMutationVariables = options.variables;
    return QueryResult<TParsed>(
      source: QueryResultSource.network,
      data: mutationData,
      options: options,
    );
  }
}
