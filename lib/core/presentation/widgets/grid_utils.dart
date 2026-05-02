import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Utilities for maintaining a consistent grid layout across the application.
class GridUtils {
  /// The standard padding for grid containers.
  static const EdgeInsets defaultPadding = EdgeInsets.all(
    AppTheme.spacingSmall,
  );

  /// The standard aspect ratio for grid items that include title and subtitle.
  static const double defaultChildAspectRatio = 1.15;

  /// Creates a standard [SliverGridDelegateWithFixedCrossAxisCount] for use in [ListPageScaffold].
  ///
  /// Defaults to 2 columns, which is typically adapted by [ListPageScaffold]
  /// for larger screens if not overridden.
  static SliverGridDelegateWithFixedCrossAxisCount createDelegate({
    int crossAxisCount = 2,
    double childAspectRatio = defaultChildAspectRatio,
  }) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: AppTheme.spacingSmall,
      mainAxisSpacing: AppTheme.spacingMedium,
      childAspectRatio: childAspectRatio,
    );
  }

  /// Calculates how many items fit in a certain number of screens.
  static int calculateItemsPerPage({
    required BuildContext context,
    required SliverGridDelegate? gridDelegate,
    required EdgeInsetsGeometry padding,
    double screens = 2.0,
    double? itemExtent,
    double? measuredItemExtent,
  }) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isGrid = gridDelegate != null;
    double stride;
    int crossAxisCount = 1;

    if (isGrid && gridDelegate is SliverGridDelegateWithFixedCrossAxisCount) {
      crossAxisCount = gridDelegate.crossAxisCount;
      final horizontalPadding = padding.horizontal;
      final availableWidth =
          MediaQuery.sizeOf(context).width - horizontalPadding;
      final itemWidth =
          (availableWidth -
              (gridDelegate.crossAxisSpacing * (crossAxisCount - 1))) /
          crossAxisCount;
      final itemHeight =
          gridDelegate.mainAxisExtent ??
          (itemWidth / gridDelegate.childAspectRatio);
      stride = itemHeight + gridDelegate.mainAxisSpacing;
    } else {
      stride = itemExtent ?? measuredItemExtent ?? 300.0;
    }

    final double rowsNeeded = (screenHeight * screens) / stride;
    return (rowsNeeded * crossAxisCount).ceil();
  }
}
