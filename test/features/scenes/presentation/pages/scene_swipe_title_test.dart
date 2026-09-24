import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/scenes/presentation/pages/scene_details_page.dart';

void main() {
  testWidgets('automatic swipe hint respects reduced motion', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: const Scaffold(
          body: SceneSwipeTitle(
            canGoPrevious: false,
            canGoNext: true,
            onPrevious: _noOp,
            onNext: _noOp,
            child: Text('Scene title'),
          ),
        ),
      ),
    );
    final initialLeft = tester.getTopLeft(find.text('Scene title')).dx;
    await tester.pump(const Duration(seconds: 2));
    expect(tester.getTopLeft(find.text('Scene title')).dx, initialLeft);
  });

  testWidgets('automatic swipe hint appears once per app launch', (
    tester,
  ) async {
    Widget title(String text) => MaterialApp(
      home: Scaffold(
        body: SceneSwipeTitle(
          key: ValueKey(text),
          canGoPrevious: true,
          canGoNext: true,
          onPrevious: _noOp,
          onNext: _noOp,
          child: Text(text),
        ),
      ),
    );

    await tester.pumpWidget(title('First scene'));
    final initialLeft = tester.getTopLeft(find.text('First scene')).dx;
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      tester.getTopLeft(find.text('First scene')).dx,
      lessThan(initialLeft),
    );
    expect(
      tester
          .widget<Opacity>(
            find.ancestor(
              of: find.byKey(const Key('scene_swipe_next')),
              matching: find.byType(Opacity),
            ),
          )
          .opacity,
      greaterThan(0),
    );
    await tester.pumpAndSettle();

    await tester.pumpWidget(title('Second scene'));
    final secondLeft = tester.getTopLeft(find.text('Second scene')).dx;
    await tester.pump(const Duration(seconds: 2));
    expect(tester.getTopLeft(find.text('Second scene')).dx, secondLeft);
  });

  testWidgets('title previews a swipe and navigates only past the threshold', (
    tester,
  ) async {
    var next = 0;
    var previous = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: SceneSwipeTitle(
                canGoPrevious: true,
                canGoNext: true,
                onPrevious: () => previous++,
                onNext: () => next++,
                child: const Text('Scene title'),
              ),
            ),
          ),
        ),
      ),
    );

    final initialLeft = tester.getTopLeft(find.text('Scene title')).dx;
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Scene title')),
    );
    await gesture.moveBy(const Offset(-30, 0));
    await tester.pump();
    expect(
      tester.getTopLeft(find.text('Scene title')).dx,
      lessThan(initialLeft),
    );
    expect(
      tester
          .widget<Opacity>(
            find.ancestor(
              of: find.byKey(const Key('scene_swipe_next')),
              matching: find.byType(Opacity),
            ),
          )
          .opacity,
      greaterThan(0),
    );
    await gesture.up();
    await tester.pumpAndSettle();
    expect(next, 0);

    await tester.drag(find.text('Scene title'), const Offset(-90, 0));
    await tester.pumpAndSettle();
    expect(next, 1);
    expect(previous, 0);

    await tester.drag(find.text('Scene title'), const Offset(90, 0));
    await tester.pumpAndSettle();
    expect(previous, 1);
  });

  testWidgets('title does not navigate beyond a queue end', (tester) async {
    var next = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: SceneSwipeTitle(
                canGoPrevious: false,
                canGoNext: true,
                onPrevious: () => fail('previous must be unavailable'),
                onNext: () => next++,
                child: const Text('Scene title'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.drag(find.text('Scene title'), const Offset(90, 0));
    await tester.pumpAndSettle();
    expect(next, 0);
  });
}

void _noOp() {}
