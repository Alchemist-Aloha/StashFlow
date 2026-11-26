import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

/// Host side of `integration_test/perf_profile_test.dart`; writes the reported
/// frame statistics to `build/$PERF_OUT.json` (default `perf_profile`).
Future<void> main() => integrationDriver(
  responseDataCallback: (data) => writeResponseData(
    data,
    testOutputFilename: Platform.environment['PERF_OUT'] ?? 'perf_profile',
  ),
);
