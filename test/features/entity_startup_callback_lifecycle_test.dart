import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'entity list pages guard startup post-frame callbacks after dispose',
    () {
      const paths = [
        'lib/features/scenes/presentation/pages/scenes_page.dart',
        'lib/features/performers/presentation/pages/performers_page.dart',
        'lib/features/studios/presentation/pages/studios_page.dart',
        'lib/features/tags/presentation/pages/tags_page.dart',
        'lib/features/galleries/presentation/pages/galleries_page.dart',
        'lib/features/images/presentation/pages/images_page.dart',
        'lib/features/groups/presentation/pages/groups_page.dart',
      ];

      for (final path in paths) {
        final source = File(path).readAsStringSync();
        expect(
          source,
          isNot(contains('addPostFrameCallback((_) {\n      final sortConfig')),
          reason: path,
        );
      }
    },
  );
}
