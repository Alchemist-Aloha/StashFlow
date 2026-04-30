import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/presentation/providers/desktop_capabilities_provider.dart';
import 'package:stash_app_flutter/features/navigation/presentation/router.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/navigation_tabs_provider.dart';
import '../../helpers/test_helpers.dart';

class MockNavigationTabsNotifier extends NavigationTabsNotifier {
  final List<NavigationTab> _initialTabs;
  MockNavigationTabsNotifier(this._initialTabs);

  @override
  List<NavigationTab> build() => _initialTabs;
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  testWidgets('Keyboard shortcuts Ctrl + 1..n navigate to correct tabs', (WidgetTester tester) async {
    // Set desktop mode
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final initialTabs = [
      const NavigationTab(type: NavigationTabType.scenes, visible: true),
      const NavigationTab(type: NavigationTabType.galleries, visible: true),
      const NavigationTab(type: NavigationTabType.performers, visible: true),
    ];

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [
        desktopCapabilitiesProvider.overrideWithValue(true),
        navigationTabsProvider.overrideWith(() => MockNavigationTabsNotifier(initialTabs)),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final goRouter = ref.watch(routerProvider);
          return MaterialApp.router(
            routerConfig: goRouter,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );

    await tester.pumpAndSettle();

    // Verify we start on Scenes (index 0)
    // We check if the NavigationRail has the first item selected instead of relying on locale strings
    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.selectedIndex, 0);

    // Press Ctrl + 2 to go to Images
    await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
    await tester.pumpAndSettle();

    // Verify we are on Images
    final rail2 = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail2.selectedIndex, 1);

    // Press Ctrl + 3 to go to Performers
    await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
    await tester.pumpAndSettle();

    final rail3 = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail3.selectedIndex, 2);

    // Press Ctrl + 1 to go back to Scenes
    await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
    await tester.pumpAndSettle();

    final rail4 = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail4.selectedIndex, 0);
  });
}
