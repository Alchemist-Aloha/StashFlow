import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/presentation/theme/app_theme.dart';
import '../../../../../core/utils/l10n_extensions.dart';
import '../../../data/local_captions/caption_options.dart';
import '../../../data/local_captions/local_caption_model.dart';
import '../../providers/local_caption_settings.dart';
import '../../providers/local_captions_provider.dart';
import '../local_caption_labels.dart';

/// A modal draft; cancellation never changes running inference or preferences.
class CaptionConfiguration {
  const CaptionConfiguration(
    this.mode,
    this.speechId,
    this.options, [
    this.translationId,
  ]) : manageModels = false;
  const CaptionConfiguration.settings()
    : mode = LocalCaptionMode.off,
      speechId = null,
      options = const CaptionOptions(),
      translationId = null,
      manageModels = true;
  final LocalCaptionMode mode;
  final String? speechId, translationId;
  final CaptionOptions options;
  final bool manageModels;
}

Future<CaptionConfiguration?> showCaptionTuningDialog(
  BuildContext context,
  LocalCaptionMode mode,
) => showDialog<CaptionConfiguration>(
  context: context,
  builder: (_) => _CaptionTuningDialog(mode: mode),
);

class _CaptionTuningDialog extends ConsumerStatefulWidget {
  const _CaptionTuningDialog({required this.mode});
  final LocalCaptionMode mode;
  @override
  ConsumerState<_CaptionTuningDialog> createState() =>
      _CaptionTuningDialogState();
}

class _CaptionTuningDialogState extends ConsumerState<_CaptionTuningDialog> {
  late LocalCaptionMode _mode;
  late CaptionOptions _options;
  LocalCaptionModel? _speech;
  String? _translationId;
  @override
  void initState() {
    super.initState();
    final settings = ref.read(localCaptionSettingsProvider);
    _mode = widget.mode;
    _options = settings.options;
    _speech = settings.canTranscribe
        ? settings.model
        : settings.downloaded.where((m) => !m.isTranslation).firstOrNull;
    _translationId = settings.translation;
    _normalizeSource();
  }

  void _normalizeSource() {
    final model = _speech;
    if (model == null) return;
    final source = _options.sourceLanguage == 'auto' && !model.canDetectLanguage
        ? model.sourceLanguages.first
        : _options.sourceLanguage;
    _options = _options.copyWith(
      sourceLanguage: model.supportsSource(source)
          ? source
          : model.canDetectLanguage
          ? 'auto'
          : model.sourceLanguages.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(localCaptionSettingsProvider);
    final speechModels = settings.downloaded
        .where((m) => !m.isTranslation)
        .toList();
    final sourceChoices = _speech == null
        ? <String>[]
        : [
            if (_speech!.canDetectLanguage) 'auto',
            if (_speech!.sourceLanguages.contains('und')) 'und',
            ...(_speech!.sourceLanguages.contains('und')
                ? captionLanguageCodes
                : _speech!.sourceLanguages),
          ];
    final validSpeech =
        _speech != null && settings.installed.contains(_speech!.id);
    final validPair =
        validSpeech &&
        (settings.sourceFor(_speech!, _options) == _options.outputLanguage ||
            settings.translationsFor(_speech!, _options).isNotEmpty);
    final translations = _speech == null
        ? <LocalCaptionModel>[]
        : settings.translationsFor(_speech!, _options);
    final preferred = translations.any((m) => m.id == _translationId)
        ? _translationId
        : null;
    final canStart =
        validSpeech && (_mode == LocalCaptionMode.transcribe || validPair);
    final detected = ref.watch(localCaptionsProvider).frame.language;
    final space = context.dimensions.spacingMedium;
    return AlertDialog(
      scrollable: true,
      title: Text(context.l10n.local_captions_configure),
      content: SizedBox(
        width: 520 * context.dimensions.fontSizeFactor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<LocalCaptionMode>(
              initialValue: _mode,
              isExpanded: true,
              decoration: InputDecoration(labelText: context.l10n.mode),
              items: [
                DropdownMenuItem(
                  value: LocalCaptionMode.transcribe,
                  child: Text(
                    context.l10n.local_captions_transcribe,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownMenuItem(
                  value: LocalCaptionMode.translate,
                  child: Text(
                    context.l10n.local_captions_translate,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              onChanged: (mode) {
                if (mode != null) setState(() => _mode = mode);
              },
            ),
            SizedBox(height: space),
            if (speechModels.isEmpty)
              Text(context.l10n.local_captions_model_missing)
            else
              DropdownButtonFormField<String>(
                initialValue: _speech?.id,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: context.l10n.local_captions_speech_models,
                ),
                items: speechModels
                    .map(
                      (m) => DropdownMenuItem(
                        value: m.id,
                        child: Text(
                          localCaptionModelLabel(context, m),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (id) => setState(() {
                  _speech = settings.find(id);
                  _normalizeSource();
                }),
              ),
            SizedBox(height: space),
            if (_speech != null)
              _language(
                context.l10n.local_captions_source,
                _options.sourceLanguage,
                sourceChoices,
                (value) => setState(
                  () => _options = _options.copyWith(sourceLanguage: value),
                ),
              ),
            if (_speech?.canDetectLanguage ?? false) ...[
              SizedBox(height: space),
              Text(context.l10n.local_captions_auto_help),
            ],
            if (detected != null && detected != 'und')
              Text(
                context.l10n.local_captions_detected(
                  localCaptionLanguageLabel(context, detected),
                ),
              ),
            if (_mode == LocalCaptionMode.translate) ...[
              SizedBox(height: space),
              _language(
                context.l10n.local_captions_output,
                _options.outputLanguage,
                captionOutputLanguages,
                (value) => setState(
                  () => _options = _options.copyWith(outputLanguage: value),
                ),
              ),
              if (translations.isNotEmpty) ...[
                SizedBox(height: space),
                DropdownButtonFormField<String>(
                  key: ValueKey(
                    'translation-$preferred-${_options.outputLanguage}-${_options.sourceLanguage}',
                  ),
                  initialValue: preferred ?? 'auto',
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.local_captions_translation_models,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'auto',
                      child: Text(
                        context.l10n.local_captions_auto_model,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ...translations.map(
                      (m) => DropdownMenuItem(
                        value: m.id,
                        child: Text(
                          localCaptionModelLabel(context, m),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (id) =>
                      setState(() => _translationId = id == 'auto' ? null : id),
                ),
              ],
              if (!validPair)
                Padding(
                  padding: EdgeInsets.only(top: space),
                  child: Text(context.l10n.local_captions_mismatch),
                ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _options.bilingual,
                title: Text(context.l10n.local_captions_bilingual),
                onChanged: (value) => setState(
                  () => _options = _options.copyWith(bilingual: value),
                ),
              ),
            ],
            SizedBox(height: space),
            _slider(
              context.l10n.local_captions_window,
              _options.windowSeconds.toDouble(),
              4,
              12,
              8,
              '${_options.windowSeconds} ${context.l10n.common_s}',
              (v) => _options = _options.copyWith(windowSeconds: v.round()),
            ),
            _slider(
              context.l10n.local_captions_threads,
              _options.threads.toDouble(),
              1,
              8,
              7,
              NumberFormat.decimalPattern(
                context.l10n.localeName,
              ).format(_options.threads),
              (v) => _options = _options.copyWith(threads: v.round()),
            ),
            if ([
              'whisper',
              'sensevoice',
              'paraformer',
              'offline-transducer',
            ].contains(_speech?.engine)) ...[
              _slider(
                context.l10n.local_captions_threshold,
                _options.speechThreshold,
                0.2,
                0.8,
                12,
                NumberFormat(
                  '0.00',
                  context.l10n.localeName,
                ).format(_options.speechThreshold),
                (v) => _options = _options.copyWith(speechThreshold: v),
              ),
              Text(context.l10n.local_captions_threshold_help),
            ],
            _slider(
              context.l10n.local_captions_delay,
              _options.delayMilliseconds.toDouble(),
              -5000,
              5000,
              100,
              '${NumberFormat('0.0', context.l10n.localeName).format(_options.delayMilliseconds / 1000)} ${context.l10n.common_s}',
              (v) => _options = _options.copyWith(delayMilliseconds: v.round()),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context, const CaptionConfiguration.settings()),
          child: Text(context.l10n.local_captions_manage),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.common_cancel),
        ),
        FilledButton(
          onPressed: canStart
              ? () => Navigator.pop(
                  context,
                  CaptionConfiguration(_mode, _speech!.id, _options, preferred),
                )
              : null,
          child: Text(context.l10n.common_apply),
        ),
      ],
    );
  }

  Widget _language(
    String title,
    String value,
    List<String> languages,
    ValueChanged<String> select,
  ) => DropdownButtonFormField<String>(
    key: ValueKey('$title-$value'),
    initialValue: value,
    isExpanded: true,
    menuMaxHeight: MediaQuery.sizeOf(context).height * 0.4,
    decoration: InputDecoration(labelText: title),
    items: languages
        .map(
          (code) => DropdownMenuItem(
            value: code,
            child: Text(
              localCaptionLanguageLabel(context, code),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
        .toList(),
    onChanged: (code) {
      if (code != null) select(code);
    },
  );

  Widget _slider(
    String title,
    double value,
    double min,
    double max,
    int divisions,
    String label,
    ValueChanged<double> change,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SizedBox(height: context.dimensions.spacingSmall),
      Text('$title: $label'),
      Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        label: label,
        semanticFormatterCallback: (_) => label,
        onChanged: (v) => setState(() => change(v)),
      ),
    ],
  );
}
