import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../scenes/data/local_captions/caption_model_catalog.dart';
import '../../../scenes/data/local_captions/local_caption_model.dart';
import '../../../scenes/presentation/providers/local_caption_settings.dart';
import '../../../scenes/presentation/widgets/local_caption_labels.dart';

/// An anchored searchable catalog, with explicit inspection and download actions.
class CaptionModelPicker extends ConsumerStatefulWidget {
  const CaptionModelPicker({
    super.key,
    required this.translation,
    this.selectedId,
    this.onSelected,
  });
  final bool translation;

  /// When supplied, selection is staged by the caller, not saved to preferences.
  final ValueChanged<LocalCaptionModel>? onSelected;
  final String? selectedId;
  @override
  ConsumerState<CaptionModelPicker> createState() => _CaptionModelPickerState();
}

class _CaptionModelPickerState extends ConsumerState<CaptionModelPicker> {
  final _search = SearchController();
  CancelToken? _inspection;
  LocalCaptionModel? _model;
  String? _repository;
  bool _changed = false,
      _resolving = false,
      _error = false,
      _incompatible = false;

  @override
  void dispose() {
    _inspection?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _choose(CaptionHubModel entry) async {
    _search.closeView(entry.repository);
    _inspection?.cancel();
    final cancel = _inspection = CancelToken();
    setState(() {
      _changed = true;
      _model = null;
      _repository = entry.repository;
      _resolving = true;
      _error = false;
      _incompatible = false;
    });
    try {
      final installed = ref
          .read(localCaptionSettingsProvider)
          .downloaded
          .where((m) => m.repository == entry.repository)
          .firstOrNull;
      final model =
          installed ??
          await ref
              .read(captionModelCatalogProvider)
              .resolve(entry, cancel: cancel);
      if (mounted && !cancel.isCancelled) setState(() => _model = model);
    } on Object catch (error) {
      if (mounted && identical(_inspection, cancel)) {
        setState(() {
          _error = true;
          _incompatible = error is UnsupportedError;
        });
      }
    } finally {
      if (mounted && identical(_inspection, cancel)) {
        setState(() => _resolving = false);
      }
    }
  }

  Future<void> _download(LocalCaptionModel model) async {
    await ref
        .read(localCaptionSettingsProvider.notifier)
        .download(model, selectAfterDownload: widget.onSelected == null);
    if (mounted &&
        ref.read(localCaptionSettingsProvider).installed.contains(model.id)) {
      widget.onSelected?.call(model);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(localCaptionSettingsProvider);
    final notifier = ref.read(localCaptionSettingsProvider.notifier);
    final selectedId = widget.onSelected != null
        ? widget.selectedId
        : widget.translation
        ? state.translation
        : state.selected;
    final model = _changed ? _model : state.find(selectedId);
    final busy = state.downloading != null || state.loading;
    final label = widget.translation
        ? context.l10n.local_captions_translation_models
        : context.l10n.local_captions_speech_models;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SearchAnchor(
          searchController: _search,
          isFullScreen: MediaQuery.sizeOf(context).width < 600,
          viewHintText: context.l10n.common_search,
          // Let the search route supply the height, including keyboard insets.
          viewBuilder: (suggestions) => Builder(
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                bottom:
                    MediaQuery.viewInsetsOf(context).bottom +
                    MediaQuery.paddingOf(context).bottom,
              ),
              child: suggestions.firstOrNull ?? const SizedBox.shrink(),
            ),
          ),
          builder: (context, controller) => Semantics(
            button: true,
            label: label,
            child: InkWell(
              onTap: busy
                  ? null
                  : () {
                      controller.clear();
                      controller.openView();
                    },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: label,
                  enabled: !busy,
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  errorMaxLines: 4,
                  errorText: _error
                      ? _incompatible
                            ? context.l10n.local_captions_incompatible
                            : context.l10n.local_captions_catalog_error
                      : null,
                ),
                child: Text(
                  _repository ??
                      model?.repository ??
                      context.l10n.common_select(label),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          suggestionsBuilder: (context, controller) => [
            Consumer(
              builder: (context, ref, _) {
                final remote = ref.watch(
                  captionHubModelsProvider(widget.translation),
                );
                final installed = ref
                    .watch(localCaptionSettingsProvider)
                    .downloaded
                    .where((m) => m.isTranslation == widget.translation);
                final models = <String, CaptionHubModel>{
                  for (final m in installed)
                    m.repository: CaptionHubModel(
                      m.repository,
                      m.engine,
                      m.source,
                      m.target,
                      m.sourceLanguages,
                      m.license,
                    ),
                  for (final m in remote.asData?.value ?? <CaptionHubModel>[])
                    m.repository: m,
                }.values;
                final codes = {
                  for (final m in models) ...m.languages,
                  for (final m in models)
                    if (m.target != null) m.target!,
                };
                final names = {
                  for (final code in codes)
                    code: localCaptionLanguageLabel(context, code),
                };
                final query = controller.text.trim().toLowerCase();
                final matches = models
                    .where(
                      (m) =>
                          ('${m.repository} ${m.engine} ${[...m.languages, if (m.target != null) m.target!].map((c) => '$c ${names[c]}').join(' ')}')
                              .toLowerCase()
                              .contains(query),
                    )
                    .toList();
                return Column(
                  children: [
                    if (remote.isLoading) const LinearProgressIndicator(),
                    if (remote.hasError)
                      ListTile(
                        title: Text(context.l10n.local_captions_catalog_error),
                        trailing: TextButton(
                          onPressed: () => ref.invalidate(
                            captionHubModelsProvider(widget.translation),
                          ),
                          child: Text(context.l10n.common_retry),
                        ),
                      ),
                    Expanded(
                      child:
                          matches.isEmpty &&
                              !remote.isLoading &&
                              !remote.hasError
                          ? Center(
                              child: Text(context.l10n.scenes_no_results_found),
                            )
                          : ListView.builder(
                              primary: false,
                              itemCount: matches.length,
                              itemBuilder: (context, index) {
                                final item = matches[index];
                                return ListTile(
                                  title: Text(item.repository),
                                  subtitle: Text(
                                    item.target == null
                                        ? item.languages.length > 1
                                              ? context
                                                    .l10n
                                                    .local_captions_multilingual
                                              : names[item.source] ??
                                                    context
                                                        .l10n
                                                        .local_captions_model_default
                                        : context.l10n.local_captions_pair(
                                            localCaptionLanguageLabel(
                                              context,
                                              item.source,
                                            ),
                                            localCaptionLanguageLabel(
                                              context,
                                              item.target!,
                                            ),
                                          ),
                                  ),
                                  onTap: () => unawaited(_choose(item)),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        if (_resolving) const LinearProgressIndicator(),
        if (model != null) ...[
          SizedBox(height: context.dimensions.spacingSmall),
          Text(
            localCaptionModelLabel(context, model),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Text(
            context.l10n.local_captions_size(
              NumberFormat(
                '0.0',
                context.l10n.localeName,
              ).format(model.bytes / 1000000),
              model.license ??
                  (model.id.startsWith('hub-')
                      ? context.l10n.common_unknown
                      : model.engine == 'whisper'
                      ? 'MIT'
                      : 'Apache-2.0'),
            ),
          ),
          SizedBox(height: context.dimensions.spacingSmall),
          if (state.downloading == model.id) ...[
            LinearProgressIndicator(
              value: state.progress,
              semanticsLabel: context.l10n.common_download,
              semanticsValue: NumberFormat.percentPattern(
                context.l10n.localeName,
              ).format(state.progress),
            ),
            TextButton(
              onPressed: notifier.cancelDownload,
              child: Text(context.l10n.common_cancel),
            ),
          ] else
            Wrap(
              spacing: context.dimensions.spacingSmall,
              children: [
                if (state.installed.contains(model.id))
                  TextButton.icon(
                    onPressed: busy || selectedId == model.id
                        ? null
                        : () {
                            if (widget.onSelected != null) {
                              widget.onSelected!(model);
                            } else {
                              unawaited(notifier.select(model.id));
                            }
                          },
                    icon: Icon(
                      selectedId == model.id
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                    ),
                    label: Text(
                      selectedId == model.id
                          ? context.l10n.selected
                          : context.l10n.local_captions_select,
                    ),
                  )
                else
                  FilledButton.icon(
                    onPressed: busy ? null : () => _download(model),
                    icon: const Icon(Icons.download),
                    label: Text(context.l10n.common_download),
                  ),
                TextButton(
                  onPressed: () => launchUrl(
                    Uri.https('huggingface.co', '/${model.repository}'),
                  ),
                  child: Text(context.l10n.common_details),
                ),
              ],
            ),
        ],
      ],
    );
  }
}
