import 'package:flutter/material.dart';

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
  static ThemeData buildTheme(Brightness brightness, Color seedColor) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
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
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
        ),
      ),
      extensions: [
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
      ],
    );
  }

  /// Default light theme using a teal seed.
  static final lightTheme = buildTheme(Brightness.light, const Color(0xFF0F766E));
  
  /// Default dark theme using a teal seed.
  static final darkTheme = buildTheme(Brightness.dark, const Color(0xFF0F766E));
}

/// Extension on [BuildContext] for ergonomic access to semantic colors and text styles.
extension AppThemeX on BuildContext {
  /// Access to the [AppColors] custom theme extension.
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  
  /// Access to the standard [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;
}
