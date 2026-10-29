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
  LocalCaptions build() => const LocalCaptions(
    frame: CaptionFrame(CaptionStatus.ready, 'phrase', 'en'),
  );
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
                    result = await showCaptionTuningDialog(context);
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

        Future<void> language(String field, String label) async {
          final menu = find.byWidgetPredicate(
            (w) => w is DropdownMenu<String> && (w.label as Text).data == field,
          );
          final input = find.descendant(
            of: menu,
            matching: find.byType(TextField),
          );
          await tester.ensureVisible(input);
          await tester.tap(input);
          await tester.pumpAndSettle();
          await tester.enterText(input, label);
          await tester.pumpAndSettle();
          final option = find.widgetWithText(MenuItemButton, label).last;
          await tester.ensureVisible(option);
          await tester.tap(option);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }

        Future<void> toggleTranslation() async {
          final toggle = find.widgetWithText(SwitchListTile, 'Translate audio');
          await tester.ensureVisible(toggle);
          await tester.tap(toggle);
          await tester.pumpAndSettle();
        }

        await open();
        expect(
          find.byType(DropdownButtonFormField<LocalCaptionMode>),
          findsNothing,
        );
        expect(find.text('Output language'), findsNothing);
        await toggleTranslation();
        expect(find.text('Detect automatically'), findsOneWidget);
        expect(find.text('Detected language: English'), findsOneWidget);
        expect(
          tester
              .widget<FilledButton>(find.widgetWithText(FilledButton, 'Apply'))
              .onPressed,
          isNotNull,
        );
        await language('Source language', 'German');
        expect(find.text('Detected language: English'), findsNothing);
        expect(
          find.textContaining('Multilingual Whisper and SenseVoice'),
          findsNothing,
        );
        expect(
          tester
              .widget<FilledButton>(find.widgetWithText(FilledButton, 'Apply'))
              .onPressed,
          isNull,
        );
        await toggleTranslation();
        expect(
          tester
              .widget<FilledButton>(find.widgetWithText(FilledButton, 'Apply'))
              .onPressed,
          isNotNull,
        );
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(result, isNull);
        expect(
          container.read(localCaptionSettingsProvider).options.sourceLanguage,
          'auto',
        );
        await open();
        expect(find.text('Output language'), findsNothing);
        await toggleTranslation();
        expect(find.text('Detect automatically'), findsOneWidget);
        await language('Source language', 'English');
        await language('Output language', 'English');
        await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
        await tester.pumpAndSettle();
        expect(result!.mode, LocalCaptionMode.translate);
        expect(result!.options.translate, isTrue);
        expect(result!.speechId, 'whisper-ja');
        expect(result!.options.sourceLanguage, 'en');
        expect(result!.options.outputLanguage, 'en');
        // Only the caller commits a returned draft, never the modal itself.
        expect(
          container.read(localCaptionSettingsProvider).options.sourceLanguage,
          'auto',
        );
        await container
            .read(localCaptionSettingsProvider.notifier)
            .configure(
              result!.speechId!,
              result!.options,
              automaticTranslation: true,
            );
        await open();
        expect(
          container.read(localCaptionSettingsProvider).options.sourceLanguage,
          'en',
        );
        expect(
          tester
              .widget<SwitchListTile>(
                find.widgetWithText(SwitchListTile, 'Translate audio'),
              )
              .value,
          isTrue,
        );
        final source = find.byWidgetPredicate(
          (w) =>
              w is DropdownMenu<String> &&
              (w.label as Text).data == 'Source language',
        );
        expect(
          tester.widget<DropdownMenu<String>>(source).initialSelection,
          'en',
        );
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
