import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';
import 'package:stash_app_flutter/features/navigation/presentation/shell_page.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/navigation_tabs_provider.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

import '../../helpers/test_helpers.dart';

void main() {
  testWidgets(
    'tab changes respect a foreign page pop veto and remain retryable',
    (tester) async {
      final allowPop = ValueNotifier(false);
      addTearDown(allowPop.dispose);
      SharedPreferences.setMockInitialValues({
        'navigation_tabs_config': jsonEncode([
          for (final type in NavigationTabType.values)
            NavigationTab(
              type: type,
              visible:
                  type == NavigationTabType.performers ||
                  type == NavigationTabType.galleries,
            ).toJson(),
        ]),
      });
      final prefs = await SharedPreferences.getInstance();
      final router = GoRouter(
        initialLocation: '/performers/detail',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, shell) =>
                ShellPage(navigationShell: shell),
            branches: [
              for (final type in NavigationTabType.values)
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/${type.id}',
                      builder: (_, _) =>
                          Scaffold(body: Text('${type.id} list')),
                      routes: [
                        GoRoute(
                          path: 'detail',
                          builder: (_, _) => ValueListenableBuilder(
                            valueListenable: allowPop,
                            builder: (_, allowed, _) => PopScope(
                              canPop:
                                  type != NavigationTabType.galleries ||
                                  allowed,
                              child: Scaffold(body: Text('${type.id} detail')),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      await pumpTestWidget(
        tester,
        prefs: prefs,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
      await tester.pumpAndSettle();
      var completed = false;
      unawaited(router.push('/galleries/detail').then((_) => completed = true));
      await tester.pumpAndSettle();
      final galleryTab = find.byIcon(Icons.perm_media);
      await tester.tap(galleryTab);
      await tester.pumpAndSettle();
      expect(find.text('galleries detail'), findsOneWidget);
      expect(completed, isFalse);

      allowPop.value = true;
      await tester.pumpAndSettle();
      await tester.tap(galleryTab);
      await tester.pumpAndSettle();
      expect(find.text('galleries list'), findsOneWidget);
      expect(completed, isTrue);
      await tester.tap(find.byIcon(Icons.people));
      await tester.pumpAndSettle();
      expect(find.text('performers detail'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
