import 'package:integration_test/integration_test_driver.dart';

/// Host side of `flutter drive` for browser integration tests such as
/// `integration_test/web_e2e_test.dart`.
Future<void> main() => integrationDriver();
