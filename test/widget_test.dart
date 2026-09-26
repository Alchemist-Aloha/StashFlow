import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  testWidgets(
    'Settings tiles use one column on phones and two on wide layouts',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.binding.setSurfaceSize(const Size(390, 844));
      await pumpTestWidget(tester, child: const SettingsHubPage());
      await tester.pumpAndSettle();

      final cards = find.byType(SettingsActionCard);
      final firstPhone = tester.getRect(cards.at(0));
      final secondPhone = tester.getRect(cards.at(1));
      expect(secondPhone.left, firstPhone.left);
      expect(secondPhone.top, greaterThan(firstPhone.bottom));
      expect(tester.takeException(), isNull);

      await tester.binding.setSurfaceSize(const Size(1200, 900));
      await tester.pumpAndSettle();

      final firstWide = tester.getRect(cards.at(0));
      final secondWide = tester.getRect(cards.at(1));
      expect(secondWide.left, greaterThan(firstWide.right));
      expect(secondWide.top, firstWide.top);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Settings tiles remain usable at the largest UI scale', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(320, 640));
    await pumpTestWidget(
      tester,
      child: Theme(
        data: AppTheme.buildTheme(
          Brightness.light,
          Colors.teal,
          fontSizeFactor: 1.5,
        ),
        child: const SettingsHubPage(),
      ),
    );
    await tester.pumpAndSettle();

    final cards = find.byType(SettingsActionCard);
    expect(
      tester.getRect(cards.at(1)).top,
      greaterThan(tester.getRect(cards.at(0)).bottom),
    );
    expect(tester.takeException(), isNull);
  });
}
