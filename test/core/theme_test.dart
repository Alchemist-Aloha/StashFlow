import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';

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
  });
}
