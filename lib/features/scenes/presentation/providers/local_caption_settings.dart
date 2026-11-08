import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../data/local_captions/caption_options.dart';
import '../../data/local_captions/caption_model_catalog.dart';
import '../../data/local_captions/local_caption_model.dart';
import '../../data/local_captions/caption_model_store.dart';

const captionModelPreference = 'local_caption_model';
const captionTranslationPreference = 'local_caption_translation_model';
const captionManifestsPreference = 'local_caption_model_manifests';
const captionOptionsPreference = 'local_caption_options';
bool get localCaptionsSupported => !kIsWeb;

final captionModelCatalogProvider = Provider<CaptionModelCatalog>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  ref.onDispose(() => dio.close(force: true));
  return CaptionModelCatalog(dio);
});
final captionHubModelsProvider =
    FutureProvider.family<List<CaptionHubModel>, bool>(
      (ref, translation) =>
          ref.watch(captionModelCatalogProvider).list(translation),
    );
final captionModelStoreProvider = FutureProvider<CaptionModelStore>((
  ref,
) async {
  final dio = Dio();
  ref.onDispose(() => dio.close(force: true));
  final root = await getApplicationSupportDirectory();
  return CaptionModelStore(Directory(p.join(root.path, 'caption-models')), dio);
});

/// Installed snapshots and preferences remain usable without the remote catalog.
class LocalCaptionSettings {
  const LocalCaptionSettings({
    this.installed = const {},
    this.models = const [],
    this.selected,
    this.translation,
    this.options = const CaptionOptions(),
    this.downloading,
    this.progress = 0,
    this.loading = true,
    this.error = false,
  });
  final Set<String> installed;
  final List<LocalCaptionModel> models;
  final String? selected, translation, downloading;
  final CaptionOptions options;
  final double progress;
  final bool loading, error;
  LocalCaptionModel? find(String? id) {
    for (final model in models) {
      if (model.id == id) return model;
    }
    return LocalCaptionModel.find(id);
  }

  LocalCaptionModel? get model => find(selected);
  LocalCaptionModel? get translationModel => find(translation);
  List<LocalCaptionModel> get downloaded => [
    for (final id in installed)
      if (find(id) != null) find(id)!,
  ];
  bool get canTranscribe =>
      model != null && !model!.isTranslation && installed.contains(selected);
  String sourceFor(LocalCaptionModel speech, CaptionOptions tuning) =>
      tuning.sourceLanguage == 'auto' && !speech.canDetectLanguage
      ? speech.sourceLanguages.first
      : tuning.sourceLanguage;

  List<LocalCaptionModel> translationsFor(
    LocalCaptionModel speech,
    CaptionOptions tuning,
  ) {
    final source = sourceFor(speech, tuning);
    final candidates = downloaded
        .where(
          (m) =>
              m.isTranslation &&
              m.supportsOutput(tuning.outputLanguage) &&
              (source == 'auto'
                  ? speech.supportsSource(m.source)
                  : m.source == source),
        )
        .toList();
    candidates.sort(
      (a, b) => a.id == b.id
          ? 0
          : a.id == translation
          ? -1
          : b.id == translation
          ? 1
          : a.id.compareTo(b.id),
    );
    return candidates;
  }

  bool get canTranslate =>
      canTranscribe &&
      (sourceFor(model!, options) == options.outputLanguage ||
          translationsFor(model!, options).isNotEmpty);
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
    List<LocalCaptionModel> models;
    try {
      models = LocalCaptionModel.parseManifests(
        prefs.getString(captionManifestsPreference),
      );
    } on Object {
      models = [];
    }
    final selected = prefs.getString(captionModelPreference);
    final translation = prefs.getString(captionTranslationPreference);
    final oldTarget = LocalCaptionModel.find(translation)?.target ?? 'en';
    return LocalCaptionSettings(
      models: models,
      selected:
          selected != null && LocalCaptionModel.validSelection(selected, false)
          ? selected
          : null,
      translation:
          translation != null &&
              LocalCaptionModel.validSelection(translation, true)
          ? translation
          : null,
      options:
          CaptionOptions.parse(prefs.getString(captionOptionsPreference)) ??
          CaptionOptions(outputLanguage: oldTarget),
      loading: localCaptionsSupported,
    );
  }

  void _update({
    Set<String>? installed,
    List<LocalCaptionModel>? models,
    String? selected,
    bool clearSelected = false,
    String? translation,
    bool clearTranslation = false,
    CaptionOptions? options,
    String? downloading,
    bool clearDownload = false,
    double? progress,
    bool? loading,
    bool? error,
  }) {
    if (!ref.mounted) return;
    state = LocalCaptionSettings(
      installed: installed ?? state.installed,
      models: models ?? state.models,
      selected: clearSelected ? null : selected ?? state.selected,
      translation: clearTranslation ? null : translation ?? state.translation,
      options: options ?? state.options,
      downloading: clearDownload ? null : downloading ?? state.downloading,
      progress: progress ?? state.progress,
      loading: loading ?? state.loading,
      error: error ?? state.error,
    );
  }

  Future<void> _saveManifests() => ref
      .read(sharedPreferencesProvider)
      .setString(
        captionManifestsPreference,
        jsonEncode(state.models.map((m) => m.toJson()).toList()),
      );

  Future<void> refresh() async {
    try {
      final store = await ref.read(captionModelStoreProvider.future);
      final installedModels = await store.readInstalled();
      if (!ref.mounted) return;
      final models = {
        for (final m in state.models) m.id: m,
        for (final m in installedModels) m.id: m,
      };
      _update(
        models: models.values.toList(),
        installed: installedModels.map((m) => m.id).toSet(),
        loading: false,
        error: false,
      );
      await _saveManifests();
    } on Object {
      _update(loading: false, error: true);
    }
  }

  /// Installs weights; dialog downloads leave the active selection unchanged.
  Future<void> download(
    LocalCaptionModel model, {
    bool selectAfterDownload = true,
  }) async {
    if (_download != null || _deleting) return;
    if (state.models.length >= 128 &&
        !state.models.any((m) => m.id == model.id)) {
      _update(error: true);
      return;
    }
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
      _update(
        installed: {...state.installed, model.id},
        models: {
          ...{for (final m in state.models) m.id: m},
          model.id: model,
        }.values.toList(),
      );
      await _saveManifests();
      if (selectAfterDownload) await select(model.id);
    } on Object {
      _update(error: cancel.cancelError?.error != 'user');
    } finally {
      _download = null;
      _update(clearDownload: true);
    }
  }

  void cancelDownload() => _download?.cancel('user');

  Future<void> select(String id) async {
    if (!state.installed.contains(id) || _deleting) return;
    final model = state.find(id);
    if (model == null) return;
    var tuning = state.options;
    if (model.isTranslation) {
      if (!model.supportsOutput(tuning.outputLanguage)) {
        tuning = tuning.copyWith(outputLanguage: model.target);
      }
      _update(translation: id, options: tuning);
    } else {
      if (!(tuning.sourceLanguage == 'auto' &&
              (model.canDetectLanguage || model.sourceLanguages.length == 1)) &&
          !model.supportsSource(tuning.sourceLanguage)) {
        tuning = tuning.copyWith(
          sourceLanguage: model.canDetectLanguage
              ? 'auto'
              : model.sourceLanguages.first,
        );
      }
      _update(selected: id, options: tuning);
    }
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(
      model.isTranslation
          ? captionTranslationPreference
          : captionModelPreference,
      id,
    );
    await prefs.setString(
      captionOptionsPreference,
      jsonEncode(tuning.toJson()),
    );
  }

  /// Applies a dialog draft atomically, so active sessions cannot use half a pair.
  Future<void> configure(
    String speechId,
    CaptionOptions options, {
    String? translationId,
    bool automaticTranslation = false,
  }) async {
    final speech = state.find(speechId);
    if (!options.isValid ||
        speech == null ||
        speech.isTranslation ||
        !state.installed.contains(speechId) ||
        !(options.sourceLanguage == 'auto' &&
                (speech.canDetectLanguage ||
                    speech.sourceLanguages.length == 1)) &&
            !speech.supportsSource(options.sourceLanguage)) {
      throw ArgumentError('Invalid caption configuration');
    }
    if (translationId != null &&
        !state
            .translationsFor(speech, options)
            .any((m) => m.id == translationId)) {
      throw ArgumentError('Incompatible translation selection');
    }
    _update(
      selected: speechId,
      options: options,
      translation: translationId,
      clearTranslation: automaticTranslation,
    );
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(captionModelPreference, speechId);
    if (automaticTranslation) {
      await prefs.remove(captionTranslationPreference);
    } else if (translationId != null) {
      await prefs.setString(captionTranslationPreference, translationId);
    }
    await prefs.setString(
      captionOptionsPreference,
      jsonEncode(options.toJson()),
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
      _update(
        installed: {...state.installed}..remove(model.id),
        models: state.models.where((m) => m.id != model.id).toList(),
        error: false,
      );
      await _saveManifests();
    } on Object {
      _update(error: true);
    } finally {
      _deleting = false;
    }
  }
}
