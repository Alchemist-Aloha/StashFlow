import 'dart:io';
import 'package:flutter/foundation.dart';

/// Returns true if the app is running in a test environment.
///
/// This checks both the dart define `FLUTTER_TEST` and the environment variable
/// `FLUTTER_TEST` (which is automatically set by `flutter test`).
bool get isTestMode =>
    const bool.fromEnvironment('FLUTTER_TEST') ||
    (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST'));
