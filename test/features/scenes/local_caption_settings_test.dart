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
import 'package:stash_app_flutter/features/scenes/presentation/providers/local_caption_settings.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/local_captions_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/widgets/local_caption_settings_section.dart';
import '../../helpers/test_helpers.dart';

class _Store extends CaptionModelStore {
  _Store() : super(Directory.systemTemp, Dio());
  final installed = <String>{};
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
          addTearDown(store.dio.close);
          await pumpTestWidget(
            tester,
            overrides: [
              captionModelStoreProvider.overrideWith((_) async => store),
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
          final tile = find.byKey(const ValueKey('caption-model-zipformer-en'));
          await tester.ensureVisible(tile);
          final download = find.descendant(
            of: tile,
            matching: find.byTooltip('Download'),
          );
          await tester.tap(download);
          await tester.pumpAndSettle();
          expect(store.installed, contains('zipformer-en'));
          expect(find.text('Selected'), findsOneWidget);
          final translation = find.byKey(
            const ValueKey('caption-model-marian-en-zh'),
          );
          await tester.ensureVisible(translation);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
