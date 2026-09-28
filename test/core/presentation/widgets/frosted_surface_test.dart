import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/presentation/widgets/bottom_sheet_panel_chrome.dart';
import 'package:stash_app_flutter/core/presentation/widgets/frosted_surface.dart';

void main() {
  group('FrostedSurface', () {
    Future<void> pumpFrosted(
      WidgetTester tester, {
      double? blurSigma,
      BorderRadiusGeometry? borderRadius,
      Color tint = const Color(0x80FFFFFF),
      BoxBorder? border,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          // A fresh key per pump so a re-pump rebuilds the surface instead of
          // reusing the mounted route from the previous configuration.
          key: UniqueKey(),
          theme: AppTheme.buildTheme(Brightness.light, const Color(0xFF0F766E)),
          home: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (_) => FrostedSurface(
                blurSigma: blurSigma ?? AppTheme.frostedBlurSigma,
                borderRadius: borderRadius,
                tint: tint,
                border: border,
                child: const SizedBox(width: 200, height: 66),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('blurs its backdrop with the system sigma', (tester) async {
      await pumpFrosted(tester);

      final filter = tester.widget<BackdropFilter>(find.byType(BackdropFilter));
      final blur = filter.filter as dynamic;
      expect(blur.sigmaX, AppTheme.frostedBlurSigma);
      expect(blur.sigmaY, AppTheme.frostedBlurSigma);
    });

    testWidgets('media chrome may scale the blur up', (tester) async {
      await pumpFrosted(tester, blurSigma: 12);

      final filter = tester.widget<BackdropFilter>(find.byType(BackdropFilter));
      final blur = filter.filter as dynamic;
      expect(blur.sigmaX, 12);
    });

    testWidgets('clips the blur to the surface bounds', (tester) async {
      await pumpFrosted(tester);
      expect(
        find.descendant(
          of: find.byType(FrostedSurface),
          matching: find.byType(ClipRect),
        ),
        findsOneWidget,
      );

      await pumpFrosted(
        tester,
        borderRadius: BorderRadius.circular(AppTheme.radiusExtraLarge),
      );
      expect(
        find.descendant(
          of: find.byType(FrostedSurface),
          matching: find.byType(ClipRRect),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(FrostedSurface),
          matching: find.byType(ClipRect),
        ),
        findsNothing,
      );
    });

    testWidgets('paints the caller tint under the child', (tester) async {
      await pumpFrosted(tester, tint: const Color(0xB80F1414));

      final tinted = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(FrostedSurface),
              matching: find.byType(Container),
            ),
          )
          .map((container) => container.decoration)
          .whereType<BoxDecoration>()
          .where((decoration) => decoration.color != null)
          .toList();

      expect(tinted, isNotEmpty);
      expect(tinted.first.color, const Color(0xB80F1414));
      expect(
        tinted.first.color!.a,
        lessThan(1.0),
        reason: 'an opaque tint would make the blur invisible work',
      );
    });

    testWidgets('keeps the shadow outside the blur clip', (tester) async {
      await pumpFrosted(tester, borderRadius: BorderRadius.circular(12));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildTheme(Brightness.light, const Color(0xFF0F766E)),
          home: Center(
            child: FrostedSurface(
              borderRadius: BorderRadius.circular(12),
              tint: const Color(0x80FFFFFF),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 24),
              ],
              child: const SizedBox(width: 100, height: 40),
            ),
          ),
        ),
      );
      await tester.pump();

      final decorated = tester.widgetList<DecoratedBox>(
        find.descendant(
          of: find.byType(FrostedSurface),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect(
        decorated.any(
          (box) =>
              (box.decoration as BoxDecoration).boxShadow?.isNotEmpty ?? false,
        ),
        isTrue,
      );
    });

    testWidgets('opaque fills skip blur and retain rounded content clipping', (
      tester,
    ) async {
      await pumpFrosted(
        tester,
        tint: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red),
      );
      expect(find.byType(BackdropFilter), findsNothing);
      expect(
        find.descendant(
          of: find.byType(FrostedSurface),
          matching: find.byType(ClipRRect),
        ),
        findsOneWidget,
      );
      final decorations = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(FrostedSurface),
              matching: find.byType(Container),
            ),
          )
          .map((c) => c.decoration)
          .whereType<BoxDecoration>();
      expect(
        decorations.any(
          (d) =>
              d.color == Colors.white &&
              d.border == Border.all(color: Colors.red),
        ),
        isTrue,
      );
      await pumpFrosted(tester, tint: const Color(0xFEFFFFFF));
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('zero blur skips the backdrop layer for translucent fills', (
      tester,
    ) async {
      await pumpFrosted(tester, blurSigma: 0);
      expect(find.byType(BackdropFilter), findsNothing);
    });

    for (final variant in ['light', 'dark', 'black']) {
      testWidgets('opaque $variant panels retain styling without blur', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.buildTheme(
              variant == 'light' ? Brightness.light : Brightness.dark,
              const Color(0xFF0F766E),
              useTrueBlack: variant == 'black',
            ),
            home: const Center(
              child: FrostedPanel(child: SizedBox(width: 100, height: 40)),
            ),
          ),
        );
        await tester.pump();
        final panel = find.byType(FrostedPanel);
        final surface = find.descendant(
          of: panel,
          matching: find.byType(FrostedSurface),
        );
        expect(surface, findsOneWidget);
        expect(tester.widget<FrostedSurface>(surface).tint.a, 1);
        expect(
          find.descendant(of: panel, matching: find.byType(BackdropFilter)),
          findsNothing,
        );
        final recipe = tester.widget<FrostedSurface>(surface);
        expect(recipe.border, isNotNull);
        expect(recipe.boxShadow, isNotEmpty);
        expect(tester.getSize(panel), const Size(102, 42));
      });
    }
  });
}
