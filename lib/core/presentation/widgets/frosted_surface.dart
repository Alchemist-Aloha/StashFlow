import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The system's frosted-glass recipe, declared once.
///
/// Every translucent surface in StashFlow funnels through this widget so the
/// blur, the hairline, the tint, and the single authored shadow stay identical
/// wherever glass appears: overlay panels, floating chrome, and the pinned app
/// bar. Depth in this system is tonal first (container steps carry the lift);
/// a frosted surface is used only where content genuinely passes behind it and
/// the blur has a job to do, never as decoration.
///
/// The caller owns the tint because the tint is context-bound:
/// [ColorScheme.surfaceContainerHigh] for chrome over app surfaces, a dark
/// scrim for chrome over full-bleed media. Everything else has a default so a
/// new frosted surface cannot invent its own recipe.
class FrostedSurface extends StatelessWidget {
  const FrostedSurface({
    required this.child,
    required this.tint,
    this.blurSigma = AppTheme.frostedBlurSigma,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
    super.key,
  });

  /// Content painted on top of the frosted layer.
  final Widget child;

  /// The surface fill. Opaque tints skip backdrop blur because they completely
  /// cover it; translucent tints retain the shared frosted treatment.
  final Color tint;

  /// Backdrop blur radius. Media-backed chrome may exceed the chrome default;
  /// see [AppTheme.frostedBlurSigma].
  final double blurSigma;

  /// Corner radius of the surface. `null` renders a square-edged surface, which
  /// is what a full-bleed bar wants.
  final BorderRadiusGeometry? borderRadius;

  /// Optional hairline. Use [Border] for per-side rules such as a bottom edge.
  final BoxBorder? border;

  /// The one authored shadow in the system. Leave `null` for chrome that has a
  /// tonal edge or a hairline instead.
  final List<BoxShadow>? boxShadow;

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius;
    Widget body = _tintedBody(radius);
    if (tint.a < 1.0 && blurSigma > 0) {
      body = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: body,
      );
    }

    // Keep content and any visible blur inside the surface bounds.
    Widget frosted = radius == null
        ? ClipRect(child: body)
        : ClipRRect(borderRadius: radius, child: body);

    // The shadow belongs to the un-clipped shell so it can fall outside the
    // surface edge instead of being cut off by the clip.
    if (boxShadow != null) {
      frosted = DecoratedBox(
        decoration: BoxDecoration(borderRadius: radius, boxShadow: boxShadow),
        child: frosted,
      );
    }

    return Container(
      width: width,
      height: height,
      constraints: constraints,
      margin: margin,
      child: frosted,
    );
  }

  Widget _tintedBody(BorderRadiusGeometry? radius) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: tint,
        border: border,
        borderRadius: radius,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: radius == null ? Clip.none : Clip.antiAlias,
        child: child,
      ),
    );
  }
}
