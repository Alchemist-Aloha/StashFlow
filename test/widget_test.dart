import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/setup/presentation/pages/settings/settings_hub_page.dart';
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
}
