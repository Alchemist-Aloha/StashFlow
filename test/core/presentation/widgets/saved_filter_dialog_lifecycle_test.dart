import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'saved filter dialog guards state updates after async save and delete',
    () {
      final source = File(
        'lib/core/presentation/widgets/saved_filter_dialog.dart',
      ).readAsStringSync();

      expect(
        source,
        contains(
          '      await widget.savePreset(name: name, existingId: match?.id);\n'
          '      if (!mounted) return;\n'
          '      setState(() {',
        ),
      );
      expect(
        source,
        contains(
          '      if (!deleted) {\n'
          "        throw StateError('Preset could not be deleted');\n"
          '      }\n'
          '\n'
          '      if (!mounted) return;\n'
          '      setState(() {',
        ),
      );
    },
  );
}
