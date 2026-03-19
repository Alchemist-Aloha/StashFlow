import 'package:flutter/material.dart';

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
      onSurfaceVariant: Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      ratingColor: Color.lerp(ratingColor, other.ratingColor, t)!,
    );
  }
}

class AppTheme {
  static const spacingSmall = 8.0;
  static const spacingMedium = 16.0;
  static const spacingLarge = 24.0;

  static const radiusSmall = 4.0;
  static const radiusMedium = 8.0;
  static const radiusLarge = 12.0;

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF673AB7), // Deep Purple
      brightness: Brightness.dark,
      surface: const Color(0xFF121212),
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      elevation: 0,
      centerTitle: false,
    ),
    extensions: [
      AppColors(
        surface: const Color(0xFF121212),
        onSurface: Colors.white,
        primary: const Color(0xFFBB86FC),
        onPrimary: Colors.black,
        secondary: const Color(0xFF03DAC6),
        onSecondary: Colors.black,
        error: const Color(0xFFCF6679),
        onError: Colors.black,
        surfaceVariant: const Color(0xFF2C2C2C),
        onSurfaceVariant: const Color(0xFFE1E1E1),
        outline: const Color(0xFF424242),
        cardBackground: const Color(0xFF1E1E1E),
        ratingColor: Colors.amber,
      ),
    ],
  );
}

extension AppThemeX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  TextTheme get textTheme => Theme.of(this).textTheme;
}
