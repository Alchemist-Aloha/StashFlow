import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/scenes/data/local_captions/caption_model_store.dart';
import 'package:stash_app_flutter/features/scenes/data/local_captions/local_caption_model.dart';
import 'package:stash_app_flutter/features/scenes/data/local_captions/caption_model_catalog.dart';
import 'package:stash_app_flutter/features/scenes/data/local_captions/caption_options.dart';
import 'package:stash_app_flutter/features/setup/presentation/widgets/caption_model_picker.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/local_caption_settings.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/local_captions_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/widgets/local_caption_settings_section.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/video_controls/caption_tuning_dialog.dart';
import '../../helpers/test_helpers.dart';

class _Store extends CaptionModelStore {
  _Store() : super(Directory.systemTemp, Dio());
  final installed = <String>{};
  @override
  Future<List<LocalCaptionModel>> readInstalled() async =>
      installed.map((id) => LocalCaptionModel.find(id)!).toList();
  @override
  Future<bool> isInstalled(LocalCaptionModel model) async =>
      installed.contains(model.id);
  @override
  Future<void> install(
    LocalCaptionModel model, {
    required CancelToken cancel,
    required void Function(double) onProgress,
  }) async {
    onProgress(0.5);
    installed.add(model.id);
    onProgress(1);
  }

  @override
  Future<void> delete(LocalCaptionModel model) async {
    installed.remove(model.id);
  }
}

class _Catalog extends CaptionModelCatalog {
  _Catalog({this.cancelInspection = false, this.failListing = false})
    : super(Dio());
  final bool cancelInspection, failListing;
  int listRequests = 0;
  @override
  Future<List<CaptionHubModel>> list(bool translation) async {
    listRequests++;
    if (failListing) throw StateError('offline');
    return LocalCaptionModel.catalog
        .where((m) => m.isTranslation == translation)
        .map(
          (m) => CaptionHubModel(
            m.repository,
            m.engine,
            m.source,
            m.target,
            m.sourceLanguages,
            m.license,
          ),
        )
        .toList();
  }

  @override
  Future<LocalCaptionModel> resolve(
    CaptionHubModel entry, {
    CancelToken? cancel,
  }) async {
    if (cancelInspection) {
      cancel!.cancel('Unexpected metadata size');
      throw cancel.cancelError!;
    }
    return LocalCaptionModel.catalog.firstWhere(
      (m) => m.repository == entry.repository,
    );
  }
}

class _IdleCaptions extends LocalCaptionsNotifier {
  @override
  LocalCaptions build() => const LocalCaptions();
}

void main() {
  test(
    'selected model pair persists and incompatible sources cannot translate',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = _Store();
      final container = ProviderContainer.test(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          captionModelStoreProvider.overrideWith((_) async => store),
        ],
      );
      final notifier = container.read(localCaptionSettingsProvider.notifier);
      await notifier.refresh();
      await notifier.download(LocalCaptionModel.find('zipformer-en')!);
      await notifier.download(LocalCaptionModel.find('marian-en-zh')!);
      expect(container.read(localCaptionSettingsProvider).canTranslate, isTrue);
      expect(prefs.getString(captionModelPreference), 'zipformer-en');
      expect(prefs.getString(captionTranslationPreference), 'marian-en-zh');
      await notifier.download(LocalCaptionModel.find('zipformer-zh')!);
      await notifier.select('zipformer-zh');
      await notifier.configure(
        'zipformer-zh',
        const CaptionOptions(sourceLanguage: 'zh', outputLanguage: 'en'),
      );
      expect(
        container.read(localCaptionSettingsProvider).canTranslate,
        isFalse,
      );
      await notifier.select('not-installed');
      expect(prefs.getString(captionModelPreference), 'zipformer-zh');
      await notifier.delete(LocalCaptionModel.find('zipformer-zh')!);
      expect(prefs.containsKey(captionModelPreference), isFalse);
      expect(
        container.read(localCaptionSettingsProvider).canTranscribe,
        isFalse,
      );
      store.dio.close();
    },
  );

  test(
    'applied options and translation choice survive transcription and restart',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = _Store();
      addTearDown(store.dio.close);
      final overrides = [
        sharedPreferencesProvider.overrideWithValue(prefs),
        captionModelStoreProvider.overrideWith((_) async => store),
      ];
      final container = ProviderContainer.test(overrides: overrides);
      final notifier = container.read(localCaptionSettingsProvider.notifier);
      await notifier.refresh();
      await notifier.download(LocalCaptionModel.find('zipformer-en')!);
      await notifier.download(LocalCaptionModel.find('marian-en-zh')!);
      const options = CaptionOptions(
        sourceLanguage: 'en',
        outputLanguage: 'zh',
        bilingual: true,
        translate: true,
        threads: 3,
        windowSeconds: 8,
        speechThreshold: 0.65,
        delayMilliseconds: 1200,
      );
      await notifier.configure(
        'zipformer-en',
        options,
        translationId: 'marian-en-zh',
      );
      // Transcription does not discard the last translation-model preference.
      await notifier.configure('zipformer-en', options);
      final restored = ProviderContainer.test(overrides: overrides);
      await restored.read(localCaptionSettingsProvider.notifier).refresh();
      final settings = restored.read(localCaptionSettingsProvider);
      expect(settings.selected, 'zipformer-en');
      expect(settings.translation, 'marian-en-zh');
      expect(settings.options.toJson(), options.toJson());
      await restored
          .read(localCaptionSettingsProvider.notifier)
          .configure('zipformer-en', options, automaticTranslation: true);
      final automatic = ProviderContainer.test(overrides: overrides);
      expect(automatic.read(localCaptionSettingsProvider).translation, isNull);
    },
  );

  testWidgets(
    'dialog downloads speech and translation without committing its draft',
    (tester) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = _Store(), catalog = _Catalog();
      addTearDown(store.dio.close);
      addTearDown(catalog.dio.close);
      CaptionConfiguration? draft;
      await pumpTestWidget(
        tester,
        overrides: [
          captionModelStoreProvider.overrideWith((_) async => store),
          captionModelCatalogProvider.overrideWithValue(catalog),
          localCaptionsProvider.overrideWith(_IdleCaptions.new),
        ],
        child: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                draft = await showCaptionTuningDialog(context);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.text('Open')),
      );
      final before = container.read(localCaptionSettingsProvider);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      Future<void> download(bool translation, String id) async {
        final expansion = find.byType(ExpansionTile).at(translation ? 1 : 0);
        await tester.ensureVisible(expansion);
        if (!tester.widget<ExpansionTile>(expansion).initiallyExpanded) {
          await tester.tap(
            find
                .descendant(of: expansion, matching: find.byType(ListTile))
                .first,
          );
        }
        await tester.pumpAndSettle();
        final picker = find.byWidgetPredicate(
          (w) => w is CaptionModelPicker && w.translation == translation,
        );
        final field = find
            .descendant(of: picker, matching: find.byType(InputDecorator))
            .first;
        await tester.ensureVisible(field);
        await tester.tap(field);
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(TextField).last,
          translation ? 'Chinese' : id,
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(ListTile, LocalCaptionModel.find(id)!.repository),
        );
        await tester.pumpAndSettle();
        final button = find
            .descendant(of: picker, matching: find.byType(FilledButton))
            .first;
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(store.installed, contains(id));
        expect(
          container.read(localCaptionSettingsProvider).selected,
          before.selected,
        );
        expect(
          container.read(localCaptionSettingsProvider).translation,
          before.translation,
        );
      }

      await download(false, 'zipformer-en');
      final toggle = find.widgetWithText(SwitchListTile, 'Translate audio');
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      await download(true, 'marian-en-zh');
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Apply'))
            .onPressed,
        isNotNull,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
      await tester.pumpAndSettle();
      expect(draft!.speechId, 'zipformer-en');
      expect(draft!.translationId, 'marian-en-zh');
      expect(draft!.options.outputLanguage, 'zh');
      expect(
        container.read(localCaptionSettingsProvider).options.toJson(),
        before.options.toJson(),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'catalog error and retry scroll above the keyboard with large text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      addTearDown(tester.view.resetViewInsets);
      final store = _Store(), catalog = _Catalog(failListing: true);
      addTearDown(store.dio.close);
      addTearDown(catalog.dio.close);
      await pumpTestWidget(
        tester,
        overrides: [
          captionModelStoreProvider.overrideWith((_) async => store),
          captionModelCatalogProvider.overrideWithValue(catalog),
          localCaptionsProvider.overrideWith(_IdleCaptions.new),
        ],
        child: Theme(
          data: AppTheme.buildTheme(
            Brightness.dark,
            Colors.teal,
            fontSizeFactor: 2,
          ),
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showCaptionTuningDialog(context),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final field = find
          .descendant(
            of: find.byType(CaptionModelPicker).first,
            matching: find.byType(InputDecorator),
          )
          .first;
      await tester.ensureVisible(field);
      await tester.tap(field);
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 250);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final retry = find.widgetWithText(TextButton, 'Retry');
      await tester.ensureVisible(retry);
      await tester.pumpAndSettle();
      expect(tester.getBottomLeft(retry).dy, lessThanOrEqualTo(318));
      final requests = catalog.listRequests;
      await tester.tap(retry);
      await tester.pumpAndSettle();
      expect(catalog.listRequests, greaterThan(requests));
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Cannot load model catalog'), findsOneWidget);
    },
  );

  test('backup selections do not enable missing weights', () async {
    SharedPreferences.setMockInitialValues({
      captionModelPreference: 'zipformer-en',
      captionTranslationPreference: 'marian-en-zh',
    });
    final prefs = await SharedPreferences.getInstance();
    final store = _Store();
    final container = ProviderContainer.test(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        captionModelStoreProvider.overrideWith((_) async => store),
      ],
    );
    await container.read(localCaptionSettingsProvider.notifier).refresh();
    expect(container.read(localCaptionSettingsProvider).canTranscribe, isFalse);
    expect(container.read(localCaptionSettingsProvider).canTranslate, isFalse);
    store.dio.close();
  });

  testWidgets(
    'cancelled metadata inspection shows recovery instead of spinning forever',
    (tester) async {
      final store = _Store(), catalog = _Catalog(cancelInspection: true);
      addTearDown(store.dio.close);
      addTearDown(catalog.dio.close);
      await pumpTestWidget(
        tester,
        overrides: [
          captionModelStoreProvider.overrideWith((_) async => store),
          captionModelCatalogProvider.overrideWithValue(catalog),
        ],
        child: const Scaffold(
          body: SingleChildScrollView(child: LocalCaptionSettingsSection()),
        ),
      );
      await tester.pumpAndSettle();
      final field = find.descendant(
        of: find.byType(CaptionModelPicker).first,
        matching: find.byType(InputDecorator),
      );
      await tester.ensureVisible(field);
      await tester.tap(field);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'zipformer-en');
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(
          ListTile,
          LocalCaptionModel.find('zipformer-en')!.repository,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.textContaining('Cannot load model catalog'), findsOneWidget);
      expect(store.installed, isEmpty);
    },
  );

  for (final scale in [0.5, 2.0]) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'model controls fit at scale $scale, $brightness and download explicitly',
        (tester) async {
          tester.view.physicalSize = const Size(360, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final store = _Store();
          final catalog = _Catalog();
          addTearDown(store.dio.close);
          addTearDown(catalog.dio.close);
          await pumpTestWidget(
            tester,
            overrides: [
              captionModelStoreProvider.overrideWith((_) async => store),
              captionModelCatalogProvider.overrideWithValue(catalog),
              localCaptionsProvider.overrideWith(_IdleCaptions.new),
            ],
            child: Theme(
              data: AppTheme.buildTheme(
                brightness,
                Colors.teal,
                fontSizeFactor: scale,
              ),
              child: const Scaffold(
                body: SingleChildScrollView(
                  child: LocalCaptionSettingsSection(),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(store.installed, isEmpty);
          Future<void> choose(int index, String query, String id) async {
            final picker = find.byType(CaptionModelPicker).at(index);
            final field = find
                .descendant(of: picker, matching: find.byType(InputDecorator))
                .first;
            await tester.ensureVisible(field);
            await tester.tap(field);
            await tester.pumpAndSettle();
            final searchList = find.byType(ListView).last;
            expect(tester.getSize(searchList).height, greaterThan(600));
            tester.view.viewInsets = const FakeViewPadding(bottom: 300);
            await tester.pumpAndSettle();
            expect(tester.getBottomLeft(searchList).dy, lessThanOrEqualTo(600));
            await tester.enterText(find.byType(TextField).last, query);
            await tester.pumpAndSettle();
            final repository = LocalCaptionModel.find(id)!.repository;
            await tester.tap(find.widgetWithText(ListTile, repository));
            tester.view.resetViewInsets();
            await tester.pumpAndSettle();
            final download = find.widgetWithText(FilledButton, 'Download');
            await tester.ensureVisible(download);
            await tester.tap(download);
            await tester.pumpAndSettle();
            expect(store.installed, contains(id));
          }

          await choose(0, 'zipformer-en', 'zipformer-en');
          await choose(1, 'Chinese', 'marian-en-zh');
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
