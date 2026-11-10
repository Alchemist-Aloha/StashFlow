import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/providers/desktop_capabilities_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/setup/presentation/pages/settings/settings_hub_page.dart';
import 'package:stash_app_flutter/features/setup/presentation/widgets/settings_page_shell.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

import 'helpers/test_helpers.dart';

void main() {
  testWidgets('Settings page shows category tiles', (
    WidgetTester tester,
  ) async {
    await pumpTestWidget(tester, child: const SettingsHubPage());
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(SettingsHubPage)),
    )!;

    expect(find.text(l10n.settings_server), findsOneWidget);
    expect(find.text(l10n.settings_playback), findsOneWidget);
    expect(find.text(l10n.settings_interface), findsOneWidget);
  });

  for (final width in [320.0, 1200.0]) {
    for (final scale in [0.8, 1.0, 1.5]) {
      for (final brightness in Brightness.values) {
        testWidgets(
          'Settings uses the Tools list layout at width $width, scale $scale, $brightness',
          (tester) async {
            addTearDown(() => tester.binding.setSurfaceSize(null));
            await tester.binding.setSurfaceSize(Size(width, 844));
            final isDesktop = width >= 1200;
            await pumpTestWidget(
              tester,
              overrides: [
                desktopCapabilitiesProvider.overrideWithValue(isDesktop),
              ],
              child: Theme(
                data: AppTheme.buildTheme(
                  brightness,
                  Colors.teal,
                  fontSizeFactor: scale,
                ),
                child: const SettingsHubPage(),
              ),
            );
            await tester.pumpAndSettle();

            expect(find.byType(SettingsPanelCard), findsOneWidget);
            final cards = find.byType(SettingsActionCard);
            expect(cards, findsNWidgets(isDesktop ? 9 : 8));
            expect(
              find.byIcon(Icons.keyboard_rounded),
              isDesktop ? findsOneWidget : findsNothing,
            );
            final dimensions = tester.element(cards.first).dimensions;
            final panel = tester.getRect(find.byType(SettingsPanelCard));
            final first = tester.getRect(cards.first);
            expect(
              first.left - panel.left,
              closeTo(dimensions.spacingMedium, 0.01),
            );
            expect(
              panel.right - first.right,
              closeTo(dimensions.spacingMedium, 0.01),
            );
            for (var index = 1; index < cards.evaluate().length; index++) {
              final previous = tester.getRect(cards.at(index - 1));
              final current = tester.getRect(cards.at(index));
              expect(current.left, first.left);
              expect(current.width, first.width);
              expect(
                current.top - previous.bottom,
                closeTo(dimensions.spacingMedium, 0.01),
              );
            }

            await tester.ensureVisible(cards.last);
            await tester.pumpAndSettle();
            expect(cards.last.hitTestable(), findsOneWidget);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}
