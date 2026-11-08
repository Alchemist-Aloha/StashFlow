import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import 'package:stash_app_flutter/features/setup/presentation/widgets/caption_model_picker.dart';
import 'package:stash_app_flutter/features/scenes/data/local_captions/caption_options.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/local_caption_settings.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/local_captions_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/video_controls/caption_tuning_dialog.dart';
import '../../helpers/test_helpers.dart';

class _Models extends LocalCaptionSettingsNotifier {
  @override
  LocalCaptionSettings build() => const LocalCaptionSettings(
    loading: false,
    selected: 'whisper-ja',
    translation: 'marian-en-zh',
    installed: {'whisper-ja', 'marian-en-zh'},
    options: CaptionOptions(outputLanguage: 'zh'),
  );
}

class _ChangingModels extends _Models {
  void setStatus({
    Set<String>? installed,
    String? downloading,
    bool loading = false,
  }) {
    state = LocalCaptionSettings(
      selected: state.selected,
      translation: state.translation,
      installed: installed ?? state.installed,
      options: state.options,
      downloading: downloading,
      progress: 0.5,
      loading: loading,
    );
  }

  @override
  void cancelDownload() => setStatus();
}

class _Idle extends LocalCaptionsNotifier {
  @override
  LocalCaptions build() => const LocalCaptions(
    frame: CaptionFrame(CaptionStatus.ready, 'phrase', 'en'),
  );
}

void main() {
  testWidgets(
    'download recovery stays visible and removed models cannot be applied',
    (tester) async {
      final models = _ChangingModels();
      await pumpTestWidget(
        tester,
        overrides: [
          localCaptionSettingsProvider.overrideWith(() => models),
          localCaptionsProvider.overrideWith(_Idle.new),
        ],
        child: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showCaptionTuningDialog(context),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final toggle = find.widgetWithText(SwitchListTile, 'Translate audio');
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      models.setStatus(downloading: 'remote-model-not-yet-in-manifests');
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Apply'))
            .onPressed,
        isNull,
      );
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      final cancelDownload = find.byIcon(Icons.close);
      await tester.ensureVisible(cancelDownload);
      await tester.tap(cancelDownload);
      await tester.pumpAndSettle();
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Apply'))
            .onPressed,
        isNotNull,
      );
      models.setStatus(loading: true);
      await tester.pump();
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Apply'))
            .onPressed,
        isNull,
      );
      models.setStatus(installed: {'marian-en-zh'});
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Source language'), findsNothing);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Apply'))
            .onPressed,
        isNull,
      );
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
    },
  );

  for (final size in [
    const Size(320, 568),
    const Size(568, 320),
    const Size(800, 1024),
    const Size(1280, 800),
  ]) {
    for (final locale in ['en', 'de']) {
      testWidgets('dialog remains usable at $size with large text / $locale', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localCaptionSettingsProvider.overrideWith(_Models.new),
              localCaptionsProvider.overrideWith(_Idle.new),
            ],
            child: MaterialApp(
              locale: Locale(locale),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: AppTheme.buildTheme(
                Brightness.dark,
                Colors.teal,
                fontSizeFactor: 2,
              ),
              home: Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () => showCaptionTuningDialog(context),
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final dialogContext = tester.element(find.byType(Dialog));
        final l10n = AppLocalizations.of(dialogContext)!;
        final translation = find.widgetWithText(
          SwitchListTile,
          l10n.local_captions_translate,
        );
        await tester.ensureVisible(translation);
        await tester.tap(translation);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final panels = find.byType(ExpansionTile);
        for (var index = 0; index < panels.evaluate().length; index++) {
          final panel = panels.at(index);
          final tile = find
              .descendant(of: panel, matching: find.byType(ListTile))
              .first;
          await tester.ensureVisible(tile);
          await tester.tap(tile);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
        for (final key in ['speech-downloads', 'translation-downloads']) {
          final panel = find.byKey(ValueKey(key));
          final header = find
              .descendant(of: panel, matching: find.byType(ListTile))
              .first;
          final picker = find.descendant(
            of: panel,
            matching: find.byType(CaptionModelPicker),
          );
          expect(tester.getSize(picker).width, tester.getSize(panel).width);
          final space = Theme.of(
            dialogContext,
          ).extension<AppDimensions>()!.spacingMedium;
          expect(
            tester.getTopLeft(picker).dy - tester.getBottomLeft(header).dy,
            greaterThanOrEqualTo(space - 0.01),
          );
          expect(
            tester.getBottomLeft(panel).dy - tester.getBottomLeft(picker).dy,
            greaterThanOrEqualTo(space - 0.01),
          );
        }
        if (size.width >= 1000) {
          expect(
            tester.getSize(find.byType(Dialog)).width,
            greaterThanOrEqualTo(800),
          );
        }
        tester.view.viewInsets = FakeViewPadding(bottom: size.height * 0.4);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final language = find.byWidgetPredicate(
          (w) =>
              w is DropdownMenu<String> &&
              (w.label as Text).data == l10n.local_captions_source,
        );
        final search = find.descendant(
          of: language,
          matching: find.byType(TextField),
        );
        await tester.ensureVisible(search);
        await tester.pumpAndSettle();
        await tester.tap(search);
        await tester.pumpAndSettle();
        await tester.enterText(search, 'en');
        await tester.pumpAndSettle();
        final english = find
            .widgetWithText(
              MenuItemButton,
              l10n.local_captions_language_name('en'),
            )
            .last;
        await tester.ensureVisible(english);
        await tester.pumpAndSettle();
        await tester.tap(english);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final cancel = find.widgetWithText(TextButton, l10n.common_cancel);
        await tester.ensureVisible(cancel);
        await tester.tap(cancel);
        await tester.pumpAndSettle();
        expect(find.byType(Dialog), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }

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

        Future<void> language(
          String field,
          String label, {
          String? query,
        }) async {
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
          await tester.enterText(input, query ?? label);
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
        await language('Source language', 'German', query: 'de');
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
