import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('scrubbing preview guards empty-sprite callback after dispose', () {
    final source = File(
      'lib/features/scenes/presentation/widgets/scrubbing_preview.dart',
    ).readAsStringSync();

    expect(
      source,
      contains(
        '          WidgetsBinding.instance.addPostFrameCallback((_) {\n'
        '            if (!mounted) return;\n'
        '            widget.onVttUnavailable?.call();',
      ),
    );
  });
}
