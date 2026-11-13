import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Utilities for maintaining a consistent grid layout across the application.
class GridUtils {
  /// The standard padding for grid containers.
  static EdgeInsets defaultPadding(BuildContext context) =>
      EdgeInsets.all(context.dimensions.spacingSmall);

  /// The standard aspect ratio for grid items that include title and subtitle.
  static const double defaultChildAspectRatio = 1.15;

  /// Creates a standard [SliverGridDelegateWithFixedCrossAxisCount] for use in [ListPageScaffold].
  ///
  /// Defaults to 2 columns, which is typically adapted by [ListPageScaffold]
  /// for larger screens if not overridden.
  static SliverGridDelegateWithFixedCrossAxisCount createDelegate(
    BuildContext context, {
    int crossAxisCount = 2,
    double childAspectRatio = defaultChildAspectRatio,
  }) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: context.dimensions.spacingSmall,
      mainAxisSpacing: context.dimensions.spacingMedium,
      childAspectRatio: childAspectRatio,
    );
  }
}
