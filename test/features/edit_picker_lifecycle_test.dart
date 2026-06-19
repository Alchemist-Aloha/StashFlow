import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('edit pages guard picker results before setState', () {
    final sceneEditPage = File(
      'lib/features/scenes/presentation/pages/scene_edit_page.dart',
    ).readAsStringSync();
    final performerEditPage = File(
      'lib/features/performers/presentation/pages/performer_edit_page.dart',
    ).readAsStringSync();

    expect(sceneEditPage, contains('if (picked != null && mounted) {'));
    expect(sceneEditPage, contains('if (result != null && mounted) {'));
    expect(sceneEditPage, contains('if (results != null && mounted) {'));
    expect(
      performerEditPage,
      contains('if (picked != null && context.mounted) {'),
    );
  });
}
