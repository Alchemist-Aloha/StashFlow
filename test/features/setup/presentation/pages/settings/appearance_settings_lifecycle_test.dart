import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppearanceSettingsPage does not register no-op focus listeners', () {
    final source = File(
      'lib/features/setup/presentation/pages/settings/appearance_settings_page.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('addListener(_onTextFieldFocusChanged)')));
    expect(source, isNot(contains('_onTextFieldFocusChanged')));
  });
}
