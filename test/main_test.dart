import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/main.dart';

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
}
