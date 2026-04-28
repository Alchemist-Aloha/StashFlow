import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/theme_mode_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/true_black_provider.dart';
import 'package:stash_app_flutter/core/presentation/providers/app_language_provider.dart';
import 'package:stash_app_flutter/main.dart';

class TestAppThemeModeNotifier extends AppThemeModeNotifier {
  @override
  ThemeMode build() => ThemeMode.dark;
}

class TestTrueBlackNotifier extends TrueBlackNotifier {
  @override
  bool build() => true;
}

class TestAppLanguageNotifier extends AppLanguageNotifier {
  @override
  Locale? build() => const Locale('fr', 'FR');
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'server_base_url': 'http://localhost:9999',
    });
  });

  testWidgets('MyApp builds correctly', (WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      bool isOverflowError = false;

      var exception = details.exception;
      if (exception is FlutterError) {
        isOverflowError = exception.diagnostics.any(
          (e) => e.value.toString().contains("A RenderFlex overflowed by"),
        );
      }

      if (isOverflowError) {
        // Ignore overflow error
        return;
      }

      // Forward to original handler
      if (originalOnError != null) {
        originalOnError(details);
      }
    };

    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);

    // Restore original handler
    FlutterError.onError = originalOnError;
  });

  testWidgets('MyApp handles theme mode and true black correctly during initialization', (WidgetTester tester) async {
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          appThemeModeProvider.overrideWith(TestAppThemeModeNotifier.new),
          trueBlackEnabledProvider.overrideWith(TestTrueBlackNotifier.new),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pump();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    
    // Verify theme mode is set to Dark
    expect(materialApp.themeMode, ThemeMode.dark);
    
    // Verify true black background logic applies
    expect(materialApp.darkTheme?.scaffoldBackgroundColor, Colors.black);
  });

  testWidgets('MyApp initializes with custom locales successfully', (WidgetTester tester) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    const testLocale = Locale('fr', 'FR');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          appLanguageProvider.overrideWith(TestAppLanguageNotifier.new),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pump();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    
    // Verify the locale is correctly passed to the app
    expect(materialApp.locale, testLocale);
  });
}
