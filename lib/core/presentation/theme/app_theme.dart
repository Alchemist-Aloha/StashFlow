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

  /// Provides default fallback colors for cases where the theme extension is missing.
  ///
  /// Derived from the same seed as the real theme, so the fallback can never
  /// drift into a second palette of hand-picked Material baseline neutrals.
  static AppColors fallback(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0F766E),
      brightness: brightness,
    );
    return AppColors(
      surface: scheme.surface,
      onSurface: scheme.onSurface,
      primary: scheme.primary,
      onPrimary: scheme.onPrimary,
      secondary: scheme.secondary,
      onSecondary: scheme.onSecondary,
      error: scheme.error,
      onError: scheme.onError,
      surfaceVariant: scheme.surfaceContainerHigh,
      onSurfaceVariant: scheme.onSurfaceVariant,
      outline: scheme.outline,
      cardBackground: scheme.surfaceContainerHighest,
      ratingColor: brightness == Brightness.dark
          ? Colors.amber.shade300
          : Colors.amber.shade700,
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
      performerAvatarSize: lerpDouble(
        performerAvatarSize,
        other.performerAvatarSize,
        t,
      )!,
      cardTitleFontSize: lerpDouble(
        cardTitleFontSize,
        other.cardTitleFontSize,
        t,
      )!,
      fontSizeFactor: lerpDouble(fontSizeFactor, other.fontSizeFactor, t)!,
      spacingSmall: lerpDouble(spacingSmall, other.spacingSmall, t)!,
      spacingMedium: lerpDouble(spacingMedium, other.spacingMedium, t)!,
      spacingLarge: lerpDouble(spacingLarge, other.spacingLarge, t)!,
      buttonHeight: lerpDouble(buttonHeight, other.buttonHeight, t)!,
    );
  }

  /// Provides default fallback dimensions for cases where the theme extension is missing.
  static const fallback = AppDimensions(
    performerAvatarSize: 16.0,
    cardTitleFontSize: 12.0,
    fontSizeFactor: 1.0,
    spacingSmall: 8.0,
    spacingMedium: 16.0,
    spacingLarge: 24.0,
    buttonHeight: 48.0,
  );
}

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

  /// Backdrop blur radius for frosted chrome over app surfaces.
  ///
  /// Media-backed chrome (fullscreen images, video overlays) scales this up
  /// deliberately, because it sits over photography rather than UI.
  static const frostedBlurSigma = 4.0;

  /// Alpha of the surface tint on frosted chrome.
  ///
  /// Chosen against the worst backdrop a bar can meet — a pure white thumbnail
  /// behind a dark header — where it still holds the title at 5.7:1 while
  /// leaving enough of the backdrop visible for the blur to read as glass.
  /// Raising this toward opaque hides the blur; lowering it puts text at risk.
  static const frostedChromeAlpha = 0.72;

  /// Alpha of the hairline on a frosted surface.
  static const frostedHairlineAlpha = 0.5;

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
    String? fontFamily,
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
        // The documented True Black steps, spelled as the literals DESIGN.md
        // sanctions rather than the nearest Material grey shades.
        onSurfaceVariant: const Color(0xFFBDBDBD),
        outline: const Color(0xFF424242),
        outlineVariant: const Color(0xFF212121),
      );
    }

    final baseTextTheme = _scaleTextTheme(
      Typography.material2021(platform: defaultTargetPlatform).black.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
        fontFamily: fontFamily,
      ),
      fontSizeFactor,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      fontFamily: fontFamily,
      textTheme: baseTextTheme.copyWith(
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          fontSize: 12 * fontSizeFactor,
        ),
        labelMedium: baseTextTheme.labelMedium?.copyWith(
          fontSize: 12 * fontSizeFactor,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        // Depth belongs to the frosted list-page header alone; a plain bar must
        // never gain the M3 scroll-under tint, which would read as an authored
        // elevation the system does not have.
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        // One app-bar voice for the whole app: the list-page header's bold,
        // tightly tracked title, so a detail, settings, or tool page does not
        // render its title in a different weight from the list it was opened
        // from. AppBar does not apply `foregroundColor` on top of this style,
        // so the colour is authored here.
        titleTextStyle: baseTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        color: colorScheme.surfaceContainerHighest,
        clipBehavior: Clip.antiAlias,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        backgroundColor: colorScheme.surfaceContainerHigh,
        side: BorderSide.none,
        // Selection swaps the chip to the accent container pair and leaves its
        // geometry alone, so a selected filter reads as the same tile in the
        // accent colour rather than as a different control.
        selectedColor: colorScheme.primaryContainer,
        secondarySelectedColor: colorScheme.primaryContainer,
        labelStyle: baseTextTheme.labelLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
        secondaryLabelStyle: baseTextTheme.labelLarge?.copyWith(
          color: colorScheme.onPrimaryContainer,
        ),
        checkmarkColor: colorScheme.onPrimaryContainer,
        iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.onPrimaryContainer);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        // The rail deliberately uses the secondary container while the bottom
        // bar uses the primary container; the two are not interchangeable.
        indicatorColor: colorScheme.secondaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        selectedIconTheme: IconThemeData(
          color: colorScheme.onSecondaryContainer,
        ),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        // Must be a real type role, not a bare colour: a style with no size
        // would opt snackbar copy out of the font-size factor.
        contentTextStyle: baseTextTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHigh,
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
          vertical: dims.spacingSmall,
        ),
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

  static TextTheme _scaleTextTheme(TextTheme theme, double factor) {
    TextStyle? scale(TextStyle? style) => style?.fontSize == null
        ? style
        : style!.copyWith(fontSize: style.fontSize! * factor);

    return theme.copyWith(
      displayLarge: scale(theme.displayLarge),
      displayMedium: scale(theme.displayMedium),
      displaySmall: scale(theme.displaySmall),
      headlineLarge: scale(theme.headlineLarge),
      headlineMedium: scale(theme.headlineMedium),
      headlineSmall: scale(theme.headlineSmall),
      titleLarge: scale(theme.titleLarge),
      titleMedium: scale(theme.titleMedium),
      titleSmall: scale(theme.titleSmall),
      bodyLarge: scale(theme.bodyLarge),
      bodyMedium: scale(theme.bodyMedium),
      bodySmall: scale(theme.bodySmall),
      labelLarge: scale(theme.labelLarge),
      labelMedium: scale(theme.labelMedium),
      labelSmall: scale(theme.labelSmall),
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
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ??
      AppColors.fallback(Theme.of(this).brightness);

  /// Access to the [AppDimensions] custom theme extension.
  AppDimensions get dimensions =>
      Theme.of(this).extension<AppDimensions>() ?? AppDimensions.fallback;

  /// Access to the standard [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Access to the configured `FontSizes` ThemeExtension.
  FontSizes get fontSizes =>
      Theme.of(this).extension<FontSizes>() ??
      FontSizes(
        tiny: 9,
        xSmall: 10,
        small: 11,
        regular: 12,
        medium: 13,
        body: 14,
        large: 16,
        xLarge: 18,
        title: 20,
        display: 24,
      );
}
