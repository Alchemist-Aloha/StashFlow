import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../data/local_captions/local_caption_model.dart';
import '../../data/local_captions/caption_model_store.dart';

const captionModelPreference = 'local_caption_model';
const captionTranslationPreference = 'local_caption_translation_model';
bool get localCaptionsSupported => !kIsWeb;

final captionModelStoreProvider = FutureProvider<CaptionModelStore>((
  ref,
) async {
  final dio = Dio();
  ref.onDispose(() => dio.close(force: true));
  final root = await getApplicationSupportDirectory();
  return CaptionModelStore(Directory(p.join(root.path, 'caption-models')), dio);
});

class LocalCaptionSettings {
  const LocalCaptionSettings({
    this.installed = const {},
    this.selected,
    this.translation,
    this.downloading,
    this.progress = 0,
    this.loading = true,
    this.error = false,
  });
  final Set<String> installed;
  final String? selected, translation, downloading;
  final double progress;
  final bool loading, error;
  LocalCaptionModel? get model => LocalCaptionModel.find(selected);
  LocalCaptionModel? get translationModel =>
      LocalCaptionModel.find(translation);
  bool get canTranscribe => model != null && installed.contains(selected);
  bool get canTranslate =>
      canTranscribe &&
      installed.contains(translation) &&
      translationModel?.source == model?.source;
}

final localCaptionSettingsProvider =
    NotifierProvider<LocalCaptionSettingsNotifier, LocalCaptionSettings>(
      LocalCaptionSettingsNotifier.new,
    );

class LocalCaptionSettingsNotifier extends Notifier<LocalCaptionSettings> {
  CancelToken? _download;
  bool _deleting = false;

  @override
  LocalCaptionSettings build() {
    final prefs = ref.read(sharedPreferencesProvider);
    ref.onDispose(() => _download?.cancel());
    if (localCaptionsSupported) unawaited(Future.microtask(refresh));
    final model = LocalCaptionModel.find(
      prefs.getString(captionModelPreference),
    );
    final translation = LocalCaptionModel.find(
      prefs.getString(captionTranslationPreference),
    );
    return LocalCaptionSettings(
      selected: model?.isTranslation == false ? model?.id : null,
      translation: translation?.isTranslation == true ? translation?.id : null,
      loading: localCaptionsSupported,
    );
  }

  void _update({
    Set<String>? installed,
    String? selected,
    bool clearSelected = false,
    String? translation,
    bool clearTranslation = false,
    String? downloading,
    bool clearDownload = false,
    double? progress,
    bool? loading,
    bool? error,
  }) {
    if (!ref.mounted) return;
    state = LocalCaptionSettings(
      installed: installed ?? state.installed,
      selected: clearSelected ? null : selected ?? state.selected,
      translation: clearTranslation ? null : translation ?? state.translation,
      downloading: clearDownload ? null : downloading ?? state.downloading,
      progress: progress ?? state.progress,
      loading: loading ?? state.loading,
      error: error ?? state.error,
    );
  }

  Future<void> refresh() async {
    try {
      final store = await ref.read(captionModelStoreProvider.future);
      final installed = <String>{};
      for (final model in LocalCaptionModel.catalog) {
        if (await store.isInstalled(model)) installed.add(model.id);
      }
      _update(installed: installed, loading: false, error: false);
    } on Object catch (_) {
      _update(loading: false, error: true);
    }
  }

  Future<void> download(LocalCaptionModel model) async {
    if (_download != null || _deleting) return;
    final cancel = _download = CancelToken();
    _update(downloading: model.id, progress: 0, error: false);
    try {
      final store = await ref.read(captionModelStoreProvider.future);
      await store.install(
        model,
        cancel: cancel,
        onProgress: (value) => _update(progress: value),
      );
      if (!ref.mounted) return;
      _update(installed: {...state.installed, model.id});
      if ((model.isTranslation ? state.translation : state.selected) == null) {
        await select(model.id);
      }
    } on Object catch (_) {
      _update(error: cancel.cancelError?.error != 'user');
    } finally {
      _download = null;
      _update(clearDownload: true);
    }
  }

  void cancelDownload() => _download?.cancel('user');

  Future<void> select(String id) async {
    if (!state.installed.contains(id) || _deleting) return;
    final model = LocalCaptionModel.find(id);
    if (model == null) return;
    if (model.isTranslation) {
      _update(translation: id);
    } else {
      _update(selected: id);
    }
    await ref
        .read(sharedPreferencesProvider)
        .setString(
          model.isTranslation
              ? captionTranslationPreference
              : captionModelPreference,
          id,
        );
  }

  Future<void> delete(LocalCaptionModel model) async {
    if (_download != null || _deleting) return;
    _deleting = true;
    try {
      if (state.selected == model.id || state.translation == model.id) {
        _update(
          clearSelected: state.selected == model.id,
          clearTranslation: state.translation == model.id,
        );
        await ref
            .read(sharedPreferencesProvider)
            .remove(
              model.isTranslation
                  ? captionTranslationPreference
                  : captionModelPreference,
            );
      }
      final store = await ref.read(captionModelStoreProvider.future);
      await store.delete(model);
      _update(installed: {...state.installed}..remove(model.id), error: false);
    } on Object catch (_) {
      _update(error: true);
    } finally {
      _deleting = false;
    }
  }
}
