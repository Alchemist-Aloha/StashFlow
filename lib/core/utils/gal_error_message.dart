import 'package:gal/gal.dart';

/// Describes why saving media to the device gallery failed.
// shortcut: English only, like before; move to ARB when these get translated.
String galErrorMessage(GalExceptionType type) => switch (type) {
  GalExceptionType.accessDenied =>
    'Permission to access the gallery is denied.',
  GalExceptionType.notEnoughSpace => 'Not enough space for storage.',
  GalExceptionType.notSupportedFormat => 'Unsupported file format.',
  GalExceptionType.unexpected => 'An unexpected error has occurred.',
};
