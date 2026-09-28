import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/widgets/section_header.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('SectionHeader', () {
    testWidgets(
      'long title wraps beside a reachable action at large UI scale',
      (tester) async {
        var tapped = false;
        await pumpTestWidget(
          tester,
          child: Theme(
            data: AppTheme.buildTheme(
              Brightness.dark,
              const Color(0xFF0F766E),
              fontSizeFactor: 1.5,
            ),
            child: Scaffold(
              body: SizedBox(
                width: 224,
                child: SectionHeader(
                  title: 'Recently added media',
                  padding: EdgeInsets.zero,
                  onViewAll: () => tapped = true,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          tester.getRect(find.byType(TextButton)).right,
          lessThanOrEqualTo(224),
        );
        await tester.tap(find.byType(TextButton));
        expect(tapped, isTrue);
      },
    );
    testWidgets('renders title correctly', (WidgetTester tester) async {
      await pumpTestWidget(
        tester,
        child: const Scaffold(body: SectionHeader(title: 'Test Title')),
      );
      await tester.pump();

      final titleFinder = find.text('Test Title');
      expect(titleFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(titleFinder);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('renders \'View all\' button when onViewAll is provided', (
      WidgetTester tester,
    ) async {
      await pumpTestWidget(
        tester,
        child: Scaffold(
          body: SectionHeader(title: 'Test Title', onViewAll: () {}),
        ),
      );
      await tester.pump();

      expect(
        find.text(
          AppLocalizations.of(
            tester.element(find.byType(SectionHeader)),
          )!.common_view_all,
        ),
        findsOneWidget,
      );
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('does not render \'View all\' button when onViewAll is null', (
      WidgetTester tester,
    ) async {
      await pumpTestWidget(
        tester,
        child: const Scaffold(body: SectionHeader(title: 'Test Title')),
      );
      await tester.pump();

      expect(
        find.text(
          AppLocalizations.of(
            tester.element(find.byType(SectionHeader)),
          )!.common_view_all,
        ),
        findsNothing,
      );
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('triggers onViewAll callback when \'View all\' is tapped', (
      WidgetTester tester,
    ) async {
      bool callbackFired = false;
      await pumpTestWidget(
        tester,
        child: Scaffold(
          body: SectionHeader(
            title: 'Test Title',
            onViewAll: () {
              callbackFired = true;
            },
          ),
        ),
      );
      await tester.pump();

      final buttonFinder = find.byType(TextButton);
      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);
      await tester.pump();

      expect(callbackFired, isTrue);
    });

    testWidgets('applies default padding when not provided', (
      WidgetTester tester,
    ) async {
      await pumpTestWidget(
        tester,
        child: const Scaffold(body: SectionHeader(title: 'Test Title')),
      );
      await tester.pump();

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
      await pumpTestWidget(
        tester,
        child: Scaffold(
          body: SectionHeader(title: 'Test Title', padding: customPadding),
        ),
      );
      await tester.pumpAndSettle();

      final paddingFinder = find.byType(Padding).first;
      final paddingWidget = tester.widget<Padding>(paddingFinder);

      expect(paddingWidget.padding, customPadding);
    });
  });
}
