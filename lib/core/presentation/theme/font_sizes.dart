import 'dart:ui';
import 'package:flutter/material.dart';

@immutable
class FontSizes extends ThemeExtension<FontSizes> {
  const FontSizes({
    required this.tiny,
    required this.xSmall,
    required this.small,
    required this.regular,
    required this.medium,
    required this.body,
    required this.large,
    required this.xLarge,
    required this.title,
    required this.display,
  });

  final double tiny; // ~9
  final double xSmall; // ~10
  final double small; // ~11
  final double regular; // ~12
  final double medium; // ~13
  final double body; // ~14
  final double large; // ~16
  final double xLarge; // ~18
  final double title; // ~20
  final double display; // ~24

  @override
  FontSizes copyWith({
    double? tiny,
    double? xSmall,
    double? small,
    double? regular,
    double? medium,
    double? body,
    double? large,
    double? xLarge,
    double? title,
    double? display,
  }) {
    return FontSizes(
      tiny: tiny ?? this.tiny,
      xSmall: xSmall ?? this.xSmall,
      small: small ?? this.small,
      regular: regular ?? this.regular,
      medium: medium ?? this.medium,
      body: body ?? this.body,
      large: large ?? this.large,
      xLarge: xLarge ?? this.xLarge,
      title: title ?? this.title,
      display: display ?? this.display,
    );
  }

  @override
  FontSizes lerp(ThemeExtension<FontSizes>? other, double t) {
    if (other is! FontSizes) return this;
    return FontSizes(
      tiny: lerpDouble(tiny, other.tiny, t)!,
      xSmall: lerpDouble(xSmall, other.xSmall, t)!,
      small: lerpDouble(small, other.small, t)!,
      regular: lerpDouble(regular, other.regular, t)!,
      medium: lerpDouble(medium, other.medium, t)!,
      body: lerpDouble(body, other.body, t)!,
      large: lerpDouble(large, other.large, t)!,
      xLarge: lerpDouble(xLarge, other.xLarge, t)!,
      title: lerpDouble(title, other.title, t)!,
      display: lerpDouble(display, other.display, t)!,
    );
  }
}

extension FontSizesX on BuildContext {
  FontSizes get fontSizes => Theme.of(this).extension<FontSizes>()!;
}
