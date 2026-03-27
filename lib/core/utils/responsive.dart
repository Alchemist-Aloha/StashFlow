import 'package:flutter/material.dart';

/// Utility class for responsive design breakpoints.
class Responsive {
  /// Width threshold for mobile devices.
  static const double mobileBreakpoint = 600;

  /// Width threshold for tablet devices.
  static const double tabletBreakpoint = 1200;

  /// Returns true if the screen width is less than [mobileBreakpoint].
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  /// Returns true if the screen width is between [mobileBreakpoint] and [tabletBreakpoint].
  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= mobileBreakpoint &&
      MediaQuery.sizeOf(context).width < tabletBreakpoint;

  /// Returns true if the screen width is greater than or equal to [tabletBreakpoint].
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;
}
