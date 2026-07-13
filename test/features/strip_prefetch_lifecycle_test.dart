import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('strip widgets guard post-frame prefetch after unmount', () {
    const paths = [
      'lib/features/galleries/presentation/widgets/gallery_strip.dart',
      'lib/features/scenes/presentation/widgets/scene_strip.dart',
    ];

    for (final path in paths) {
      final source = File(path).readAsStringSync();
      expect(
        source,
        contains(
          'WidgetsBinding.instance.addPostFrameCallback((_) {\n'
          '      if (!context.mounted) return;',
        ),
        reason: path,
      );
    }
  });
}
