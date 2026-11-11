import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/presentation/providers/app_language_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/widgets/app_language_picker.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  testWidgets('picking a language saves it and closes the sheet', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    var closed = false;

    await pumpTestWidget(
      tester,
      prefs: prefs,
      child: Consumer(
        builder: (context, ref, _) => TextButton(
          onPressed: () async {
            await showAppLanguagePicker(context, ref);
            closed = true;
          },
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    expect(prefs.getString(appLanguagePreferenceKey), 'es');
    expect(closed, isTrue);
  });
}
