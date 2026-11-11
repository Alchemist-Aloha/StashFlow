import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/images/presentation/widgets/zoomable_image.dart';

void main() {
  late PageController controller;

  // 800x600 viewport; a 1:2 portrait image fits as a 300x600 column.
  Future<ZoomableImageState> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    controller = PageController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ZoomablePagerPinch(
          child: PageView.builder(
            controller: controller,
            itemCount: 2,
            itemBuilder: (_, _) => ZoomableImage(
              pageController: controller,
              axis: Axis.horizontal,
              contentSize: const Size(40, 80),
              child: const ColoredBox(color: Colors.red),
            ),
          ),
        ),
      ),
    );
    return tester.state<ZoomableImageState>(find.byType(ZoomableImage).first);
  }

  Future<void> pinch(WidgetTester tester, double spread) async {
    const center = Offset(400, 300);
    final a = await tester.startGesture(center - const Offset(50, 0));
    final b = await tester.startGesture(center + const Offset(50, 0));
    for (var i = 0; i < 10; i++) {
      await a.moveBy(Offset(-spread / 20, 0));
      await b.moveBy(Offset(spread / 20, 0));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await a.up();
    await b.up();
    await tester.pumpAndSettle();
  }

  testWidgets('pinch zooms and springs back inside the scale limits', (
    tester,
  ) async {
    final zoom = await pump(tester);

    await pinch(tester, 100); // span 100 -> 200
    expect(zoom.scale, closeTo(2, 0.05));

    await pinch(tester, 2000);
    expect(zoom.scale, ZoomableImage.maxScale);

    await pinch(tester, -95);
    await pinch(tester, -95);
    await pinch(tester, -95);
    expect(zoom.scale, 1);
    expect(zoom.offset, Offset.zero);
  });

  testWidgets('pans within the fitted image, not the letterbox', (
    tester,
  ) async {
    final zoom = await pump(tester);
    await tester.tapAt(const Offset(400, 300));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(const Offset(400, 300));
    await tester.pumpAndSettle();
    expect(zoom.scale, ZoomableImage.doubleTapScale);

    // At 3x the column is 900 wide, so it pans at most 50px either way.
    final drag = await tester.startGesture(const Offset(400, 300));
    for (var i = 0; i < 4; i++) {
      await drag.moveBy(const Offset(20, 40));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await drag.up();
    await tester.pumpAndSettle();
    // Displayed left edge = 250 * 3 + offset.dx, pinned to the viewport's 0.
    expect(250 * 3 + zoom.offset.dx, closeTo(0, 0.01));
    expect(controller.page, 0);
  });

  testWidgets('mouse wheel zooms without scrolling the pager', (tester) async {
    final zoom = await pump(tester);
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(pointer.hover(const Offset(400, 300)));
    await tester.sendEventToBinding(pointer.scroll(const Offset(0, -400)));
    await tester.pump();
    expect(zoom.scale, closeTo(2, 0.01));
    expect(controller.page, 0);
  });

  testWidgets('pinch during a page animation zooms the settling page', (
    tester,
  ) async {
    await pump(tester);
    unawaited(
      controller.animateToPage(
        1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.linear,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(controller.page, greaterThan(0.5));

    const center = Offset(400, 300);
    final a = await tester.startGesture(center - const Offset(50, 0));
    final b = await tester.startGesture(center + const Offset(50, 0));
    for (var i = 0; i < 10; i++) {
      await a.moveBy(const Offset(-5, 0));
      await b.moveBy(const Offset(5, 0));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await a.up();
    await b.up();
    await tester.pumpAndSettle();

    expect(controller.page, 1);
    final zoom = tester.state<ZoomableImageState>(find.byType(ZoomableImage));
    expect(zoom.scale, closeTo(2, 0.05));
  });
}
