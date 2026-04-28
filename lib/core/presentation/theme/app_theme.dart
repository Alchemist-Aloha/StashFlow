import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'font_sizes.dart';

/// Custom theme extension for StashFlow-specific semantic colors.
///
/// This provides a type-safe way to access colors that aren't part of the
/// standard Material [ColorScheme], such as specific ratings or custom surface levels.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.surface,
    required this.onSurface,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.error,
    required this.onError,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.outline,
    required this.cardBackground,
    required this.ratingColor,
  });

  final Color surface;
  final Color onSurface;
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color error;
  final Color onError;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color cardBackground;
  final Color ratingColor;

  @override
  AppColors copyWith({
    Color? surface,
    Color? onSurface,
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? onSecondary,
    Color? error,
    Color? onError,
    Color? surfaceVariant,
    Color? onSurfaceVariant,
    Color? outline,
    Color? cardBackground,
    Color? ratingColor,
  }) {
    return AppColors(
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      outline: outline ?? this.outline,
      cardBackground: cardBackground ?? this.cardBackground,
      ratingColor: ratingColor ?? this.ratingColor,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      onSurfaceVariant: Color.lerp(
        onSurfaceVariant,
        other.onSurfaceVariant,
        t,
      )!,
      outline: Color.lerp(outline, other.outline, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      ratingColor: Color.lerp(ratingColor, other.ratingColor, t)!,
    );
  }
}

@immutable
class AppDimensions extends ThemeExtension<AppDimensions> {
  const AppDimensions({
    required this.performerAvatarSize,
    required this.cardTitleFontSize,
    required this.fontSizeFactor,
    required this.spacingSmall,
    required this.spacingMedium,
    required this.spacingLarge,
    required this.buttonHeight,
  });

  final double performerAvatarSize;
  final double cardTitleFontSize;
  final double fontSizeFactor;
  final double spacingSmall;
  final double spacingMedium;
  final double spacingLarge;
  final double buttonHeight;

  @override
  AppDimensions copyWith({
    double? performerAvatarSize,
    double? cardTitleFontSize,
    double? fontSizeFactor,
    double? spacingSmall,
    double? spacingMedium,
    double? spacingLarge,
    double? buttonHeight,
  }) {
    return AppDimensions(
      performerAvatarSize: performerAvatarSize ?? this.performerAvatarSize,
      cardTitleFontSize: cardTitleFontSize ?? this.cardTitleFontSize,
      fontSizeFactor: fontSizeFactor ?? this.fontSizeFactor,
      spacingSmall: spacingSmall ?? this.spacingSmall,
      spacingMedium: spacingMedium ?? this.spacingMedium,
      spacingLarge: spacingLarge ?? this.spacingLarge,
      buttonHeight: buttonHeight ?? this.buttonHeight,
    );
  }

  @override
  AppDimensions lerp(ThemeExtension<AppDimensions>? other, double t) {
    if (other is! AppDimensions) return this;
    return AppDimensions(
      performerAvatarSize:
          lerpDouble(performerAvatarSize, other.performerAvatarSize, t)!,
      cardTitleFontSize:
          lerpDouble(cardTitleFontSize, other.cardTitleFontSize, t)!,
      fontSizeFactor:
          lerpDouble(fontSizeFactor, other.fontSizeFactor, t)!,
      spacingSmall:
          lerpDouble(spacingSmall, other.spacingSmall, t)!,
      spacingMedium:
          lerpDouble(spacingMedium, other.spacingMedium, t)!,
      spacingLarge:
          lerpDouble(spacingLarge, other.spacingLarge, t)!,
      buttonHeight:
          lerpDouble(buttonHeight, other.buttonHeight, t)!,
    );
  }
}

/// The central design system for StashFlow.
///
/// This class defines standard constants for spacing and border radii,
/// ensuring visual consistency across all pages and widgets.
class AppTheme {
  /// Standard padding/margin for secondary elements (8dp).
  static const spacingSmall = 8.0;

  /// Primary layout spacing used between major UI components (16dp).
  static const spacingMedium = 16.0;

  /// Larger spacing for grouping distinct sections (24dp).
  static const spacingLarge = 24.0;

  /// Corner radius for standard small elements like chips.
  static const radiusSmall = 8.0;

  /// Corner radius for standard cards and containers.
  static const radiusMedium = 12.0;

  /// Corner radius for large modal-like components.
  static const radiusLarge = 16.0;

  /// Corner radius for major surface areas.
  static const radiusExtraLarge = 28.0;

  /// Builds a [ThemeData] instance based on the provided [brightness] and [seedColor].
  ///
  /// Configures Material 3, custom component themes (AppBars, Cards, Buttons),
  /// and attaches the [AppColors] extension.
  static ThemeData buildTheme(
    Brightness brightness,
    Color seedColor, {
    bool useTrueBlack = false,
    double? cardTitleFontSize,
    double? performerAvatarSize,
    double fontSizeFactor = 1.0,
  }) {
    final dims = AppDimensions(
      performerAvatarSize: (performerAvatarSize ?? 16.0) * fontSizeFactor,
      cardTitleFontSize: (cardTitleFontSize ?? 12.0) * fontSizeFactor,
      fontSizeFactor: fontSizeFactor,
      spacingSmall: 8.0 * fontSizeFactor,
      spacingMedium: 16.0 * fontSizeFactor,
      spacingLarge: 24.0 * fontSizeFactor,
      buttonHeight: 48.0 * fontSizeFactor,
    );

    final isDark = brightness == Brightness.dark;
    var colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    if (isDark && useTrueBlack) {
      colorScheme = colorScheme.copyWith(
        surface: Colors.black,
        onSurface: Colors.white,
        surfaceContainer: Colors.black,
        surfaceContainerLow: Colors.black,
        surfaceContainerLowest: Colors.black,
        surfaceContainerHigh: const Color(0xFF121212), // Subtle lift
        surfaceContainerHighest: const Color(0xFF1A1A1A), // Card/Input lift
        onSurfaceVariant: Colors.grey.shade400,
        outline: Colors.grey.shade800,
        outlineVariant: Colors.grey.shade900,
      );
    }

    final baseTextTheme = Typography.material2021(platform: defaultTargetPlatform)
        .black
        .apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
          fontSizeFactor: fontSizeFactor,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: baseTextTheme.copyWith(
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          fontSize: 12 * fontSizeFactor,
        ),
        labelMedium: baseTextTheme.labelMedium?.copyWith(
          fontSize: 12 * fontSizeFactor,
          color: colorScheme.onSurface.withValues(alpha: 0.75),
        ),
        labelSmall: baseTextTheme.labelSmall?.copyWith(
          fontSize: 10 * fontSizeFactor,
          color: colorScheme.onSurface.withValues(alpha: 0.75),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20 * fontSizeFactor,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: dims.spacingMedium,
          vertical: dims.spacingMedium,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: colorScheme.primaryContainer,
          selectedForegroundColor: colorScheme.onPrimaryContainer,
          padding: EdgeInsets.symmetric(
            horizontal: dims.spacingSmall,
            vertical: dims.spacingSmall / 2,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: Size.fromHeight(dims.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: dims.spacingLarge,
            vertical: dims.spacingMedium,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: Size.fromHeight(dims.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          side: BorderSide(color: colorScheme.outline),
          padding: EdgeInsets.symmetric(
            horizontal: dims.spacingLarge,
            vertical: dims.spacingMedium,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: dims.spacingMedium,
            vertical: dims.spacingSmall,
          ),
        ),
      ),
      extensions: [
        FontSizes(
          tiny: 9 * fontSizeFactor,
          xSmall: 10 * fontSizeFactor,
          small: 11 * fontSizeFactor,
          regular: 12 * fontSizeFactor,
          medium: 13 * fontSizeFactor,
          body: 14 * fontSizeFactor,
          large: 16 * fontSizeFactor,
          xLarge: 18 * fontSizeFactor,
          title: 20 * fontSizeFactor,
          display: 24 * fontSizeFactor,
        ),
        AppColors(
          surface: colorScheme.surface,
          onSurface: colorScheme.onSurface,
          primary: colorScheme.primary,
          onPrimary: colorScheme.onPrimary,
          secondary: colorScheme.secondary,
          onSecondary: colorScheme.onSecondary,
          error: colorScheme.error,
          onError: colorScheme.onError,
          surfaceVariant: colorScheme.surfaceContainerHigh,
          onSurfaceVariant: colorScheme.onSurfaceVariant,
          outline: colorScheme.outline,
          cardBackground: colorScheme.surfaceContainerHighest,
          ratingColor: isDark ? Colors.amber.shade300 : Colors.amber.shade700,
        ),
        dims,
      ],
    );
  }

  /// Default light theme using a teal seed.
  static final lightTheme = buildTheme(
    Brightness.light,
    const Color(0xFF0F766E),
  );

  /// Default dark theme using a teal seed.
  static final darkTheme = buildTheme(Brightness.dark, const Color(0xFF0F766E));
}

/// Extension on [BuildContext] for ergonomic access to semantic colors and text styles.
extension AppThemeX on BuildContext {
  /// Access to the [AppColors] custom theme extension.
  AppColors get colors => Theme.of(this).extension<AppColors>()!;

  /// Access to the [AppDimensions] custom theme extension.
  AppDimensions get dimensions => Theme.of(this).extension<AppDimensions>()!;

  /// Access to the standard [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Access to the configured `FontSizes` ThemeExtension.
  FontSizes get fontSizes => Theme.of(this).extension<FontSizes>()!;
}
