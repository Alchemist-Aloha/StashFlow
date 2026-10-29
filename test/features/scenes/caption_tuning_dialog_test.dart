import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/scenes/data/local_captions/caption_options.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/local_caption_settings.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/local_captions_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/video_controls/caption_tuning_dialog.dart';
import '../../helpers/test_helpers.dart';

class _Models extends LocalCaptionSettingsNotifier {
  @override
  LocalCaptionSettings build() => const LocalCaptionSettings(
    selected: 'whisper-ja',
    translation: 'marian-en-zh',
    installed: {'whisper-ja', 'marian-en-zh'},
    options: CaptionOptions(outputLanguage: 'zh'),
  );
}

class _Idle extends LocalCaptionsNotifier {
  @override
  LocalCaptions build() => const LocalCaptions();
}

void main() {
  for (final scale in [0.5, 2.0]) {
    for (final brightness in Brightness.values) {
      testWidgets('dialog drafts are atomic and fit at $scale / $brightness', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(360, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        CaptionConfiguration? result;
        await pumpTestWidget(
          tester,
          overrides: [
            localCaptionSettingsProvider.overrideWith(_Models.new),
            localCaptionsProvider.overrideWith(_Idle.new),
          ],
          child: Theme(
            data: AppTheme.buildTheme(
              brightness,
              Colors.teal,
              fontSizeFactor: scale,
            ),
            child: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () async {
                    result = await showCaptionTuningDialog(
                      context,
                      LocalCaptionMode.translate,
                    );
                  },
                  child: const Text('Open tuning'),
                ),
              ),
            ),
          ),
        );
        final container = ProviderScope.containerOf(
          tester.element(find.text('Open tuning')),
        );
        Future<void> open() async {
          await tester.tap(find.text('Open tuning'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }

        Future<void> language(
          String field,
          String label, {
          double delta = 200,
        }) async {
          final input = find.byWidgetPredicate(
            (w) => w is InputDecorator && w.decoration.labelText == field,
          );
          await tester.ensureVisible(input);
          await tester.tap(input);
          await tester.pumpAndSettle();
          final scroll = find.byType(Scrollable).last;
          final option = find.descendant(
            of: scroll,
            matching: find.text(label),
          );
          await tester.scrollUntilVisible(option, delta, scrollable: scroll);
          await Scrollable.ensureVisible(
            tester.element(option),
            alignment: 0.5,
          );
          await tester.pumpAndSettle();
          await tester.tap(option);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }

        await open();
        expect(find.text('Detect automatically'), findsOneWidget);
        expect(
          tester
              .widget<FilledButton>(find.widgetWithText(FilledButton, 'Apply'))
              .onPressed,
          isNotNull,
        );
        await language('Source language', 'German');
        expect(
          tester
              .widget<FilledButton>(find.widgetWithText(FilledButton, 'Apply'))
              .onPressed,
          isNull,
        );
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(result, isNull);
        expect(
          container.read(localCaptionSettingsProvider).options.sourceLanguage,
          'auto',
        );
        await open();
        expect(find.text('Detect automatically'), findsOneWidget);
        await language('Source language', 'English');
        await language('Output language', 'English', delta: -200);
        await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
        await tester.pumpAndSettle();
        expect(result!.speechId, 'whisper-ja');
        expect(result!.options.sourceLanguage, 'en');
        expect(result!.options.outputLanguage, 'en');
        // Only the caller commits a returned draft, never the modal itself.
        expect(
          container.read(localCaptionSettingsProvider).options.sourceLanguage,
          'auto',
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
