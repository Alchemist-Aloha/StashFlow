import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stash_app_flutter/features/scenes/presentation/pages/scenes_page.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/performers/presentation/pages/performers_page.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_list_provider.dart';
import 'package:stash_app_flutter/features/studios/presentation/pages/studios_page.dart';
import 'package:stash_app_flutter/features/studios/presentation/providers/studio_list_provider.dart';
import 'package:stash_app_flutter/features/tags/presentation/pages/tags_page.dart';
import 'package:stash_app_flutter/features/tags/presentation/providers/tag_list_provider.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

import 'helpers/test_helpers.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('Global Empty States', () {
    testWidgets('Scenes page shows empty message', (tester) async {
      final mockRepo = MockSceneRepository()..withEmpty();
      await pumpTestWidget(
        tester,
        prefs: prefs,
        overrides: [sceneRepositoryProvider.overrideWithValue(mockRepo)],
        child: const ScenesPage(),
      );
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(ScenesPage)),
      )!;
      expect(find.text(l10n.common_no_items), findsOneWidget);
    });

    testWidgets('Performers page shows empty message', (tester) async {
      final mockRepo = MockPerformerRepository()..withEmpty();
      await pumpTestWidget(
        tester,
        prefs: prefs,
        overrides: [performerRepositoryProvider.overrideWithValue(mockRepo)],
        child: const PerformersPage(),
      );
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(PerformersPage)),
      )!;
      expect(find.text(l10n.common_no_items), findsOneWidget);
    });

    testWidgets('Studios page shows empty message', (tester) async {
      final mockRepo = MockStudioRepository()..withEmpty();
      await pumpTestWidget(
        tester,
        prefs: prefs,
        overrides: [studioRepositoryProvider.overrideWithValue(mockRepo)],
        child: const StudiosPage(),
      );
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(StudiosPage)),
      )!;
      expect(find.text(l10n.common_no_items), findsOneWidget);
    });

    testWidgets('Tags page shows empty message', (tester) async {
      final mockRepo = MockTagRepository()..withEmpty();
      await pumpTestWidget(
        tester,
        prefs: prefs,
        overrides: [tagRepositoryProvider.overrideWithValue(mockRepo)],
        child: const TagsPage(),
      );
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(tester.element(find.byType(TagsPage)))!;
      expect(find.text(l10n.common_no_items), findsOneWidget);
    });
  });

  group('Global Error States & Retry', () {
    testWidgets('Scenes page shows error and retries', (tester) async {
      final mockRepo = MockSceneRepository()..withError('Network Error');
      await pumpTestWidget(
        tester,
        prefs: prefs,
        overrides: [sceneRepositoryProvider.overrideWithValue(mockRepo)],
        child: const ScenesPage(),
      );
      await tester.pumpAndSettle();

      expect(find.errorView(message: 'Network Error'), findsOneWidget);
      expect(find.retryButton(), findsOneWidget);

      // Change mock to success
      mockRepo.withData([]);
      await tester.tap(find.retryButton());
      // Use pump instead of pumpAndSettle to avoid timeout with loading indicator
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(ScenesPage)),
      )!;
      expect(find.errorView(), findsNothing);
      expect(find.text(l10n.common_no_items), findsOneWidget);
    });

    testWidgets('Performers page shows error and retries', (tester) async {
      final mockRepo = MockPerformerRepository()
        ..withError('Failed to fetch performers');
      await pumpTestWidget(
        tester,
        prefs: prefs,
        overrides: [performerRepositoryProvider.overrideWithValue(mockRepo)],
        child: const PerformersPage(),
      );
      await tester.pumpAndSettle();

      expect(
        find.errorView(message: 'Failed to fetch performers'),
        findsOneWidget,
      );

      mockRepo.withData([]);
      await tester.tap(find.retryButton());
      // Use pump instead of pumpAndSettle to avoid timeout with loading indicator
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(PerformersPage)),
      )!;
      expect(find.text(l10n.common_no_items), findsOneWidget);
    });
  });
}
