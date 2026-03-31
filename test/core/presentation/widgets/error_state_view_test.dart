import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/widgets/error_state_view.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );
  }

  group('ErrorStateView', () {
    testWidgets('renders the error message correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(const ErrorStateView(message: 'Something went wrong')),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('renders the default \'Retry\' button when onRetry is provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(ErrorStateView(message: 'Error', onRetry: () {})),
      );

      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('does not render a retry button when onRetry is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(const ErrorStateView(message: 'Error')),
      );

      expect(find.byType(FilledButton), findsNothing);
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('uses custom retryLabel when provided alongside onRetry', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(ErrorStateView(
          message: 'Error',
          onRetry: () {},
          retryLabel: 'Try Again',
        )),
      );

      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('triggers onRetry callback when the retry button is tapped', (WidgetTester tester) async {
      bool callbackFired = false;

      await tester.pumpWidget(
        buildTestApp(ErrorStateView(
          message: 'Error',
          onRetry: () {
            callbackFired = true;
          },
        )),
      );

      final buttonFinder = find.byType(FilledButton);
      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(callbackFired, isTrue);
    });
  });
}
