import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';

void main() {
  group('AppColors', () {
    const testColors1 = AppColors(
      surface: Color(0xFF111111),
      onSurface: Color(0xFF222222),
      primary: Color(0xFF333333),
      onPrimary: Color(0xFF444444),
      secondary: Color(0xFF555555),
      onSecondary: Color(0xFF666666),
      error: Color(0xFF777777),
      onError: Color(0xFF888888),
      surfaceVariant: Color(0xFF999999),
      onSurfaceVariant: Color(0xFFAAAAAA),
      outline: Color(0xFFBBBBBB),
      cardBackground: Color(0xFFCCCCCC),
      ratingColor: Color(0xFFDDDDDD),
    );

    const testColors2 = AppColors(
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFFEEEEEE),
      primary: Color(0xFFDDDDDD),
      onPrimary: Color(0xFFCCCCCC),
      secondary: Color(0xFFBBBBBB),
      onSecondary: Color(0xFFAAAAAA),
      error: Color(0xFF999999),
      onError: Color(0xFF888888),
      surfaceVariant: Color(0xFF777777),
      onSurfaceVariant: Color(0xFF666666),
      outline: Color(0xFF555555),
      cardBackground: Color(0xFF444444),
      ratingColor: Color(0xFF333333),
    );

    test('constructor assigns all fields correctly', () {
      expect(testColors1.surface, const Color(0xFF111111));
      expect(testColors1.onSurface, const Color(0xFF222222));
      expect(testColors1.primary, const Color(0xFF333333));
      expect(testColors1.onPrimary, const Color(0xFF444444));
      expect(testColors1.secondary, const Color(0xFF555555));
      expect(testColors1.onSecondary, const Color(0xFF666666));
      expect(testColors1.error, const Color(0xFF777777));
      expect(testColors1.onError, const Color(0xFF888888));
      expect(testColors1.surfaceVariant, const Color(0xFF999999));
      expect(testColors1.onSurfaceVariant, const Color(0xFFAAAAAA));
      expect(testColors1.outline, const Color(0xFFBBBBBB));
      expect(testColors1.cardBackground, const Color(0xFFCCCCCC));
      expect(testColors1.ratingColor, const Color(0xFFDDDDDD));
    });

    test('copyWith updates fields correctly', () {
      final updated = testColors1.copyWith(
        surface: const Color(0xFF000000),
        primary: const Color(0xFFFFFFFF),
      );

      expect(updated.surface, const Color(0xFF000000));
      expect(updated.onSurface, testColors1.onSurface);
      expect(updated.primary, const Color(0xFFFFFFFF));
      expect(updated.onPrimary, testColors1.onPrimary);
      expect(updated.secondary, testColors1.secondary);
      expect(updated.onSecondary, testColors1.onSecondary);
      expect(updated.error, testColors1.error);
      expect(updated.onError, testColors1.onError);
      expect(updated.surfaceVariant, testColors1.surfaceVariant);
      expect(updated.onSurfaceVariant, testColors1.onSurfaceVariant);
      expect(updated.outline, testColors1.outline);
      expect(updated.cardBackground, testColors1.cardBackground);
      expect(updated.ratingColor, testColors1.ratingColor);
    });

    test('lerp interpolates correctly', () {
      final lerped = testColors1.lerp(testColors2, 0.5);

      expect(lerped.surface, Color.lerp(testColors1.surface, testColors2.surface, 0.5));
      expect(lerped.primary, Color.lerp(testColors1.primary, testColors2.primary, 0.5));
      expect(lerped.ratingColor, Color.lerp(testColors1.ratingColor, testColors2.ratingColor, 0.5));
    });

    test('lerp returns this if other is not AppColors', () {
      final lerped = testColors1.lerp(null, 0.5);
      expect(lerped, testColors1);
    });
  });

  group('AppTheme', () {
    test('constants have expected values', () {
      expect(AppTheme.spacingSmall, 8.0);
      expect(AppTheme.spacingMedium, 16.0);
      expect(AppTheme.spacingLarge, 24.0);
      expect(AppTheme.radiusSmall, 8.0);
      expect(AppTheme.radiusMedium, 12.0);
      expect(AppTheme.radiusLarge, 16.0);
      expect(AppTheme.radiusExtraLarge, 28.0);
    });

    test('buildTheme returns ThemeData with AppColors extension', () {
      final theme = AppTheme.buildTheme(Brightness.light, Colors.blue);
      expect(theme.brightness, Brightness.light);

      final colors = theme.extension<AppColors>();
      expect(colors, isNotNull);
      expect(colors!.ratingColor, Colors.amber.shade700);
      expect(colors.surface, theme.colorScheme.surface);
      expect(colors.cardBackground, theme.colorScheme.surfaceContainerHighest);
    });

    test('buildTheme with dark brightness has correct rating color', () {
      final theme = AppTheme.buildTheme(Brightness.dark, Colors.blue);
      final colors = theme.extension<AppColors>();
      expect(colors!.ratingColor, Colors.amber.shade300);
    });

    test('lightTheme is light brightness', () {
      expect(AppTheme.lightTheme.brightness, Brightness.light);
    });

    test('darkTheme is dark brightness', () {
      expect(AppTheme.darkTheme.brightness, Brightness.dark);
    });
  });

  group('AppThemeX', () {
    testWidgets('context.colors retrieves AppColors', (tester) async {
      late AppColors colors;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) {
              colors = context.colors;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(colors, isNotNull);
      expect(colors.surface, AppTheme.lightTheme.colorScheme.surface);
    });

    testWidgets('context.textTheme retrieves TextTheme', (tester) async {
      late TextTheme textTheme;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) {
              textTheme = context.textTheme;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(textTheme, AppTheme.lightTheme.textTheme);
    });
  });
}
