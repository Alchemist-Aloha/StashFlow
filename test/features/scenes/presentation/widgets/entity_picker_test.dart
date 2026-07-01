import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/performers/domain/entities/performer.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/entity_picker.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

import '../../../../helpers/test_helpers.dart';

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
}
