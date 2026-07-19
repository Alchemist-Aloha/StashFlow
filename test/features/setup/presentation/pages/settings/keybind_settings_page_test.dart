import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/features/setup/presentation/pages/settings/keybind_settings_page.dart';

import '../../../../../helpers/test_helpers.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('groups shortcuts by context and confirms reset', (tester) async {
    await pumpTestWidget(tester, child: const KeybindSettingsPage());
    await tester.pumpAndSettle();

    expect(find.text('Global Navigation'), findsOneWidget);
    expect(find.text('Video Player'), findsOneWidget);
    expect(find.text('Image Viewer'), findsOneWidget);
    expect(find.text('Alt + Arrow Left'), findsOneWidget);

    await tester.tap(find.text('Reset to Defaults'));
    await tester.pumpAndSettle();
    expect(find.text('Reset keyboard shortcuts?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('capture rejects reserved keys and Escape cancels', (
    tester,
  ) async {
    await pumpTestWidget(tester, child: const KeybindSettingsPage());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(OutlinedButton).first);
    await tester.pumpAndSettle();
    expect(find.text('Assign Shortcut'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(
      find.text('Tab is reserved for keyboard focus navigation.'),
      findsOneWidget,
    );

    await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
    await tester.pump();
    expect(
      find.text(
        'This shortcut is reserved by the browser or operating system.',
      ),
      findsOneWidget,
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Assign Shortcut'), findsNothing);
  });
}
