import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/widgets/section_header.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );
  }

  group('SectionHeader', () {
    testWidgets('renders title correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(const SectionHeader(title: 'Test Title')),
      );

      final titleFinder = find.text('Test Title');
      expect(titleFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(titleFinder);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('renders \'View all\' button when onViewAll is provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(SectionHeader(title: 'Test Title', onViewAll: () {})),
      );

      expect(find.text('View all'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('does not render \'View all\' button when onViewAll is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(const SectionHeader(title: 'Test Title')),
      );

      expect(find.text('View all'), findsNothing);
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('triggers onViewAll callback when \'View all\' is tapped', (
      WidgetTester tester,
    ) async {
      bool callbackFired = false;
      await tester.pumpWidget(
        buildTestApp(
          SectionHeader(
            title: 'Test Title',
            onViewAll: () {
              callbackFired = true;
            },
          ),
        ),
      );

      final buttonFinder = find.byType(TextButton);
      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(callbackFired, isTrue);
    });

    testWidgets('applies default padding when not provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(const SectionHeader(title: 'Test Title')),
      );

      final paddingFinder = find.byType(Padding).first;
      final paddingWidget = tester.widget<Padding>(paddingFinder);

      expect(
        paddingWidget.padding,
        const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMedium,
          vertical: AppTheme.spacingSmall,
        ),
      );
    });

    testWidgets('applies custom padding when provided', (
      WidgetTester tester,
    ) async {
      const customPadding = EdgeInsets.all(20.0);
      await tester.pumpWidget(
        buildTestApp(
          const SectionHeader(title: 'Test Title', padding: customPadding),
        ),
      );

      final paddingFinder = find.byType(Padding).first;
      final paddingWidget = tester.widget<Padding>(paddingFinder);

      expect(paddingWidget.padding, customPadding);
    });
  });
}
