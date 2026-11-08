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
import '../../../../setup/presentation/widgets/caption_model_picker.dart';

/// A modal draft; cancelling keeps installed downloads but discards configuration.
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

Future<CaptionConfiguration?> showCaptionTuningDialog(BuildContext context) =>
    showDialog<CaptionConfiguration>(
      context: context,
      builder: (_) => const _CaptionTuningDialog(),
    );

class _CaptionTuningDialog extends ConsumerStatefulWidget {
  const _CaptionTuningDialog();
  @override
  ConsumerState<_CaptionTuningDialog> createState() =>
      _CaptionTuningDialogState();
}

class _CaptionTuningDialogState extends ConsumerState<_CaptionTuningDialog> {
  late CaptionOptions _options;
  LocalCaptionModel? _speech;
  String? _translationId;
  @override
  void initState() {
    super.initState();
    final settings = ref.read(localCaptionSettingsProvider);
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
        validSpeech &&
        (!_options.translate || validPair) &&
        !settings.loading &&
        settings.downloading == null;
    final downloading = settings.find(settings.downloading);
    final detected = ref.watch(localCaptionsProvider).frame.language;
    final space = context.dimensions.spacingMedium;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          namesRoute: true,
          header: true,
          child: Text(
            context.l10n.local_captions_configure,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(height: space),
        if (settings.loading) const LinearProgressIndicator(),
        if (settings.downloading != null) ...[
          Text(
            downloading == null
                ? context.l10n.common_download
                : localCaptionModelLabel(context, downloading),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          SizedBox(height: context.dimensions.spacingSmall),
          LinearProgressIndicator(
            value: settings.progress,
            semanticsLabel: context.l10n.common_download,
            semanticsValue: NumberFormat.percentPattern(
              context.l10n.localeName,
            ).format(settings.progress),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: ref
                  .read(localCaptionSettingsProvider.notifier)
                  .cancelDownload,
              icon: const Icon(Icons.close),
              label: Text(context.l10n.local_captions_cancel_download),
            ),
          ),
          SizedBox(height: space),
        ],
        if (speechModels.isEmpty)
          Text(context.l10n.local_captions_model_missing)
        else
          DropdownButtonFormField<String>(
            key: ValueKey(validSpeech ? _speech!.id : null),
            initialValue: validSpeech ? _speech!.id : null,
            isExpanded: true,
            decoration: InputDecoration(
              label: Text(
                context.l10n.local_captions_speech_models,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
        ExpansionTile(
          key: const ValueKey('speech-downloads'),
          tilePadding: EdgeInsets.zero,
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          childrenPadding: EdgeInsets.symmetric(vertical: space),
          initiallyExpanded: speechModels.isEmpty,
          title: Text(context.l10n.local_captions_download_speech),
          children: [
            CaptionModelPicker(
              translation: false,
              selectedId: _speech?.id,
              onSelected: (model) => setState(() {
                _speech = model;
                _normalizeSource();
              }),
            ),
            if (settings.error)
              Text(
                context.l10n.local_captions_model_error,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
        SizedBox(height: space),
        if (validSpeech)
          _language(
            context.l10n.local_captions_source,
            _options.sourceLanguage,
            sourceChoices,
            (value) => setState(
              () => _options = _options.copyWith(sourceLanguage: value),
            ),
          ),
        if (validSpeech &&
            _speech!.canDetectLanguage &&
            _options.sourceLanguage == 'auto') ...[
          SizedBox(height: space),
          Text(context.l10n.local_captions_auto_help),
        ],
        if (_options.sourceLanguage == 'auto' &&
            detected != null &&
            detected != 'und')
          Text(
            context.l10n.local_captions_detected(
              localCaptionLanguageLabel(context, detected),
            ),
          ),
        Divider(height: context.dimensions.spacingLarge),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: _options.translate,
          title: Text(context.l10n.local_captions_translate),
          onChanged: (value) =>
              setState(() => _options = _options.copyWith(translate: value)),
        ),
        if (_options.translate) ...[
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
                label: Text(
                  context.l10n.local_captions_translation_models,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
          ExpansionTile(
            key: const ValueKey('translation-downloads'),
            tilePadding: EdgeInsets.zero,
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            childrenPadding: EdgeInsets.symmetric(vertical: space),
            initiallyExpanded: !validPair,
            title: Text(context.l10n.local_captions_download_translation),
            children: [
              CaptionModelPicker(
                translation: true,
                selectedId: _translationId,
                onSelected: (model) => setState(() {
                  _translationId = model.id;
                  if (!model.supportsOutput(_options.outputLanguage)) {
                    _options = _options.copyWith(outputLanguage: model.target);
                  }
                }),
              ),
              if (settings.error)
                Text(
                  context.l10n.local_captions_model_error,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
          if (!validPair)
            Padding(
              padding: EdgeInsets.only(top: space),
              child: Text(
                context.l10n.local_captions_mismatch,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _options.bilingual,
            title: Text(context.l10n.local_captions_bilingual),
            onChanged: (value) =>
                setState(() => _options = _options.copyWith(bilingual: value)),
          ),
        ],
        Divider(height: context.dimensions.spacingLarge),
        ExpansionTile(
          key: const ValueKey('caption-advanced'),
          tilePadding: EdgeInsets.zero,
          title: Text(context.l10n.local_captions_advanced),
          children: [
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
        SizedBox(height: space),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: () =>
                Navigator.pop(context, const CaptionConfiguration.settings()),
            icon: const Icon(Icons.storage_rounded),
            label: Text(context.l10n.local_captions_manage),
          ),
        ),
      ],
    );
    final actions = OverflowBar(
      spacing: context.dimensions.spacingSmall,
      overflowSpacing: context.dimensions.spacingSmall,
      alignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.common_cancel),
        ),
        FilledButton(
          onPressed: canStart
              ? () => Navigator.pop(
                  context,
                  CaptionConfiguration(
                    _options.translate
                        ? LocalCaptionMode.translate
                        : LocalCaptionMode.transcribe,
                    _speech!.id,
                    _options,
                    preferred,
                  ),
                )
              : null,
          child: Text(context.l10n.common_apply),
        ),
      ],
    );
    return Dialog(
      insetPadding: EdgeInsets.all(context.dimensions.spacingSmall),
      constraints: const BoxConstraints(maxWidth: 800),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // A keyboard or landscape window must not squeeze out the form.
          final scrollActions =
              constraints.maxHeight < context.dimensions.buttonHeight * 4;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.all(space),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      content,
                      if (scrollActions) ...[SizedBox(height: space), actions],
                    ],
                  ),
                ),
              ),
              if (!scrollActions)
                Padding(
                  padding: EdgeInsets.fromLTRB(space, 0, space, space),
                  child: actions,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _language(
    String title,
    String value,
    List<String> languages,
    ValueChanged<String> select,
  ) => LayoutBuilder(
    builder: (context, constraints) {
      final menuHeight =
          (MediaQuery.sizeOf(context).height -
              MediaQuery.viewInsetsOf(context).bottom) *
          0.4;
      return DropdownMenu<String>(
        key: ValueKey('$title-$value'),
        initialSelection: value,
        expandedInsets: EdgeInsets.zero,
        menuHeight: menuHeight,
        menuStyle: MenuStyle(
          maximumSize: WidgetStatePropertyAll(
            Size(constraints.maxWidth, menuHeight),
          ),
        ),
        label: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        hintText: context.l10n.common_search,
        enableFilter: true,
        requestFocusOnTap: true,
        filterCallback: (entries, query) => entries
            .where(
              (entry) => '${entry.value} ${entry.label}'.toLowerCase().contains(
                query.trim().toLowerCase(),
              ),
            )
            .toList(),
        dropdownMenuEntries: [
          for (final code in languages)
            DropdownMenuEntry(
              value: code,
              label: localCaptionLanguageLabel(context, code),
              labelWidget: Text(
                localCaptionLanguageLabel(context, code),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onSelected: (code) {
          if (code != null) select(code);
        },
      );
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
