import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/settings_page.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';

void main() {
  testWidgets('Settings page shows server fields', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const SettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('GraphQL server URL'), findsOneWidget);
    expect(find.text('API key'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
