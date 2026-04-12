import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_subtitle_overlay.dart';

void main() {
  testWidgets(
    'multiline subtitle stays centered and ratio-positioned on mobile and tablet',
    (tester) async {
      const subtitle = 'First subtitle line\nSecond subtitle line';
      const bottomRatio = 0.15;
      const containerKey = Key('subtitle_test_container');

      Future<void> pumpOverlay(Size size) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  key: containerKey,
                  width: size.width,
                  height: size.height,
                  child: Stack(
                    children: const [
                      SceneSubtitleOverlay(
                        text: subtitle,
                        constraints: BoxConstraints(
                          maxWidth: 390,
                          maxHeight: 844,
                        ),
                        bottomRatio: bottomRatio,
                        fontSize: 18,
                        horizontalPadding: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
      }

      // Mobile
      const mobile = Size(390, 844);
      await pumpOverlay(mobile);

      final mobileText = tester.widget<Text>(find.text(subtitle));
      expect(mobileText.textAlign, TextAlign.center);

      final mobileContainerRect = tester.getRect(find.byKey(containerKey));
      final mobileBox = tester.getRect(find.byType(DecoratedBox));
      final mobileBottomInset = mobileContainerRect.bottom - mobileBox.bottom;
      expect(mobileBottomInset, closeTo(mobile.height * bottomRatio, 1.0));

      // Tablet
      const tablet = Size(1024, 1366);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                key: containerKey,
                width: tablet.width,
                height: tablet.height,
                child: Stack(
                  children: const [
                    SceneSubtitleOverlay(
                      text: subtitle,
                      constraints: BoxConstraints(
                        maxWidth: 1024,
                        maxHeight: 1366,
                      ),
                      bottomRatio: bottomRatio,
                      fontSize: 18,
                      horizontalPadding: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final tabletText = tester.widget<Text>(find.text(subtitle));
      expect(tabletText.textAlign, TextAlign.center);

      final tabletContainerRect = tester.getRect(find.byKey(containerKey));
      final tabletBox = tester.getRect(find.byType(DecoratedBox));
      final tabletBottomInset = tabletContainerRect.bottom - tabletBox.bottom;
      expect(tabletBottomInset, closeTo(tablet.height * bottomRatio, 1.0));
    },
  );
}
