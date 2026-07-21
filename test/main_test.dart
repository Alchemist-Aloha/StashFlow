import 'dart:io';

import 'package:flutter/gestures.dart';
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

  test('Windows startup waits until the configured window is ready', () {
    final source = File('lib/main.dart').readAsStringSync();

    expect(source, contains('const windowOptions = WindowOptions('));
    expect(source, contains('minimumSize: Size(800, 600)'));
    expect(source, contains('windowManager.waitUntilReadyToShow('));
    expect(source, contains('await windowManager.maximize()'));
    expect(source, contains('await windowManager.show()'));
    expect(source, contains('await windowManager.focus()'));
  });

  testWidgets('desktop scroll behavior supports mouse drag scrolling', (
    WidgetTester tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        scrollBehavior: const DesktopScrollBehavior(),
        home: SizedBox(
          width: 300,
          height: 100,
          child: ListView.builder(
            controller: controller,
            scrollDirection: Axis.horizontal,
            itemExtent: 200,
            itemCount: 10,
            itemBuilder: (context, index) => Text('Item $index'),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(ListView)),
      kind: PointerDeviceKind.mouse,
    );
    await gesture.moveBy(const Offset(-200, 0));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(controller.offset, greaterThan(0));
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

  testWidgets(
    'MyApp handles theme mode and true black correctly during initialization',
    (WidgetTester tester) async {
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
    },
  );

  testWidgets('MyApp initializes with custom locales successfully', (
    WidgetTester tester,
  ) async {
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

  testWidgets('MyApp supports only script-specific Chinese locales', (
    WidgetTester tester,
  ) async {
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

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(
      materialApp.supportedLocales,
      contains(
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
      ),
    );
    expect(
      materialApp.supportedLocales,
      contains(
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      ),
    );
    expect(materialApp.supportedLocales, isNot(contains(const Locale('zh'))));
  });

  testWidgets('StartupErrorApp shows a visible startup failure', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      StartupErrorApp(
        error: StateError('controlled startup failure'),
        stackTrace: StackTrace.current,
      ),
    );

    expect(find.text('StashFlow failed to start'), findsOneWidget);
    expect(find.textContaining('controlled startup failure'), findsOneWidget);
  });
}
