import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/widgets/marquee_text.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 100, // Constraint width to test scrolling
            child: child,
          ),
        ),
      ),
    );
  }

  testWidgets('MarqueeText builds successfully and displays text', (
    WidgetTester tester,
  ) async {
    const text = 'Short';
    await tester.pumpWidget(buildTestWidget(const MarqueeText(text: text)));

    expect(find.byType(MarqueeText), findsOneWidget);
    expect(find.text(text), findsOneWidget);
  });

  testWidgets('MarqueeText updates properly when text changes', (
    WidgetTester tester,
  ) async {
    // Run async so that any Future.delayed can finish.
    await tester.runAsync(() async {
      await tester.pumpWidget(
        buildTestWidget(
          const MarqueeText(
            text: 'Initial Text',
            pauseDuration: Duration(milliseconds: 1),
            scrollDuration: Duration(milliseconds: 1),
          ),
        ),
      );
      expect(find.text('Initial Text'), findsOneWidget);

      await tester.pumpWidget(
        buildTestWidget(
          const MarqueeText(
            text: 'Updated Text',
            pauseDuration: Duration(milliseconds: 1),
            scrollDuration: Duration(milliseconds: 1),
          ),
        ),
      );
      await tester.pump(); // Allow didUpdateWidget to process

      expect(find.text('Initial Text'), findsNothing);
      expect(find.text('Updated Text'), findsOneWidget);

      // Destroy the widget
      await tester.pumpWidget(const SizedBox());
      // Small delay to allow mounted check to return false after Future.delayed finishes
      await Future.delayed(const Duration(milliseconds: 5));
    });
  });

  testWidgets('MarqueeText triggers scroll logic for long text', (
    WidgetTester tester,
  ) async {
    const longText =
        'This is a very long text that should definitely trigger the marquee scrolling behavior because it exceeds the constrained width of 100 pixels.';

    await tester.runAsync(() async {
      // Set smaller durations to speed up test execution
      await tester.pumpWidget(
        buildTestWidget(
          const MarqueeText(
            text: longText,
            scrollDuration: Duration(milliseconds: 50),
            pauseDuration: Duration(milliseconds: 10),
          ),
        ),
      );

      expect(find.byType(MarqueeText), findsOneWidget);
      expect(find.text(longText), findsOneWidget);

      // Verify it's a SingleChildScrollView
      final scrollViewFinder = find.descendant(
        of: find.byType(MarqueeText),
        matching: find.byType(SingleChildScrollView),
      );
      expect(scrollViewFinder, findsOneWidget);

      final SingleChildScrollView scrollView = tester.widget(scrollViewFinder);
      expect(scrollView.scrollDirection, Axis.horizontal);
      expect(scrollView.physics, isA<NeverScrollableScrollPhysics>());

      // Wait a moment for scroll logic to kick in
      await Future.delayed(const Duration(milliseconds: 100));
      await tester.pump();

      // Ensure all timers finish so test cleans up correctly
      await tester.pumpWidget(const SizedBox());
      await Future.delayed(const Duration(milliseconds: 20));
    });
  });
}
