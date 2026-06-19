import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PerformerEditPage does not create text controllers in build', () {
    final source = File(
      'lib/features/performers/presentation/pages/performer_edit_page.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('controller: TextEditingController(')));
  });
}
