import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/presentation/widgets/grid_utils.dart';

void main() {
  group('AppTheme', () {
    const seedColor = Colors.deepPurple;

    test(
      'buildTheme returns dark theme with AMOLED black when useTrueBlack is true',
      () {
        final theme = AppTheme.buildTheme(
          Brightness.dark,
          seedColor,
          useTrueBlack: true,
        );

        expect(theme.brightness, Brightness.dark);
        expect(theme.scaffoldBackgroundColor, Colors.black);
        expect(theme.colorScheme.surface, Colors.black);
        expect(theme.colorScheme.surfaceContainer, Colors.black);
      },
    );

    test(
      'buildTheme returns standard dark theme when useTrueBlack is false',
      () {
        final theme = AppTheme.buildTheme(
          Brightness.dark,
          seedColor,
          useTrueBlack: false,
        );

        expect(theme.brightness, Brightness.dark);
        expect(theme.scaffoldBackgroundColor, isNot(Colors.black));
        expect(theme.colorScheme.surface, isNot(Colors.black));
      },
    );

    test('buildTheme returns light theme even if useTrueBlack is true', () {
      final theme = AppTheme.buildTheme(
        Brightness.light,
        seedColor,
        useTrueBlack: true,
      );

      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, isNot(Colors.black));
    });

    test('component dimensions scale with the UI size factor', () {
      final theme = AppTheme.buildTheme(
        Brightness.light,
        seedColor,
        fontSizeFactor: 1.5,
      );

      expect(
        theme.inputDecorationTheme.contentPadding,
        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      );
      expect(
        theme.filledButtonTheme.style?.minimumSize?.resolve({}),
        const Size.fromHeight(72),
      );
      expect(
        theme.textButtonTheme.style?.padding?.resolve({}),
        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      );
    });

    testWidgets('grid dimensions scale with the UI size factor', (
      tester,
    ) async {
      late SliverGridDelegateWithFixedCrossAxisCount delegate;
      late EdgeInsets padding;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildTheme(
            Brightness.light,
            seedColor,
            fontSizeFactor: 1.5,
          ),
          home: Builder(
            builder: (context) {
              delegate = GridUtils.createDelegate(context);
              padding = GridUtils.defaultPadding(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(delegate.crossAxisSpacing, 12);
      expect(delegate.mainAxisSpacing, 24);
      expect(padding, const EdgeInsets.all(12));
    });
  });
}
