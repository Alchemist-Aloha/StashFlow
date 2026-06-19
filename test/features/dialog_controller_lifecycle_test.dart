import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dialog-local text controllers are disposed after modal completion', () {
    final securitySettings = File(
      'lib/features/setup/presentation/pages/settings/security_settings_page.dart',
    ).readAsStringSync();
    final castSelectionSheet = File(
      'lib/features/scenes/presentation/widgets/video_controls/cast_selection_sheet.dart',
    ).readAsStringSync();

    expect(
      securitySettings,
      contains(
        '    } finally {\n'
        '      controller.dispose();\n'
        '      confirmController.dispose();\n'
        '    }\n'
        '  }',
      ),
    );
    expect(
      castSelectionSheet,
      contains(
        '      } finally {\n'
        '        pinController.dispose();\n'
        '      }\n'
        '    }();',
      ),
    );
  });
}
