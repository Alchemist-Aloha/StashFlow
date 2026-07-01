import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/performers/domain/entities/performer.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/entity_picker.dart';
import 'package:stash_app_flutter/features/tags/domain/entities/tag.dart';
import 'package:stash_app_flutter/features/tags/presentation/providers/tag_list_provider.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

import '../../../../helpers/test_helpers.dart';

class FilteringTagRepository extends MockGraphQLTagRepository {
  @override
  Future<List<Tag>> findTags({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
    bool favoritesOnly = false,
  }) async {
    final tags = await super.findTags(
      page: page,
      perPage: perPage,
      filter: filter,
      sort: sort,
      descending: descending,
      favoritesOnly: favoritesOnly,
    );
    if (filter == null || filter.isEmpty) return tags;
    return tags
        .where((tag) => tag.name.toLowerCase().contains(filter.toLowerCase()))
        .toList();
  }
}

void main() {
  testWidgets('performer picker search does not update performer page search', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final performerRepo = MockGraphQLPerformerRepository()
      ..setData([
        const Performer(
          id: 'performer-1',
          name: 'Performer One',
          urls: [],
          birthdate: null,
          aliasList: [],
          favorite: false,
          imagePath: null,
          sceneCount: 0,
          imageCount: 0,
          galleryCount: 0,
          groupCount: 0,
          tagIds: [],
          tagNames: [],
        ),
      ]);
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        performerRepositoryProvider.overrideWithValue(performerRepo),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: EntityPicker<Performer>(
            title: 'Select Performers',
            providerType: 'performer',
            multiSelect: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Performer');
    await tester.pumpAndSettle();

    expect(container.read(performerSearchQueryProvider), '');
  });

  testWidgets('multi picker keeps initial tags when search excludes them', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final tagRepo = FilteringTagRepository()
      ..setData([
        const Tag(
          id: 'tag-old',
          name: 'Old Tag',
          sceneCount: 1,
          imageCount: 0,
          galleryCount: 0,
          performerCount: 0,
          favorite: false,
        ),
        const Tag(
          id: 'tag-new',
          name: 'New Tag',
          sceneCount: 0,
          imageCount: 0,
          galleryCount: 0,
          performerCount: 0,
          favorite: false,
        ),
      ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          tagRepositoryProvider.overrideWithValue(tagRepo),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: _PickerHost(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'New');
    await tester.pumpAndSettle();

    expect(find.text('Old Tag'), findsOneWidget);
    expect(find.text('New Tag'), findsOneWidget);

    await tester.tap(find.text('New Tag'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('tag-old,tag-new'), findsOneWidget);
  });
}

class _PickerHost extends StatefulWidget {
  const _PickerHost();

  @override
  State<_PickerHost> createState() => _PickerHostState();
}

class _PickerHostState extends State<_PickerHost> {
  List<Tag> _selected = const [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(_selected.map((tag) => tag.id).join(',')),
          TextButton(
            onPressed: () async {
              final result = await showDialog<List<Tag>>(
                context: context,
                builder: (context) => const EntityPicker<Tag>(
                  title: 'Select Tags',
                  providerType: 'tag',
                  multiSelect: true,
                  initialSelection: ['tag-old'],
                ),
              );
              if (result != null) {
                setState(() => _selected = result);
              }
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }
}
