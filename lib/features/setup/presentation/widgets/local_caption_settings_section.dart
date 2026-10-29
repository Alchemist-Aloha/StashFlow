import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../scenes/data/local_captions/local_caption_model.dart';
import '../../../scenes/presentation/providers/local_caption_settings.dart';
import '../../../scenes/presentation/providers/local_captions_provider.dart';
import '../../../scenes/presentation/widgets/local_caption_labels.dart';
import 'settings_page_shell.dart';

/// Explicit downloads, selection and removal of local speech/translation models.
class LocalCaptionSettingsSection extends ConsumerWidget {
  const LocalCaptionSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(localCaptionSettingsProvider);
    final notifier = ref.read(localCaptionSettingsProvider.notifier);
    return SettingsSectionCard(
      title: context.l10n.local_captions_title,
      subtitle: localCaptionsSupported
          ? context.l10n.local_captions_help
          : context.l10n.local_captions_unsupported,
      child: !localCaptionsSupported
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.loading) const LinearProgressIndicator(),
                for (final translation in [false, true]) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: context.dimensions.spacingMedium,
                    ),
                    child: Text(
                      translation
                          ? context.l10n.local_captions_translation_models
                          : context.l10n.local_captions_speech_models,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  for (final model in LocalCaptionModel.catalog.where(
                    (m) => m.isTranslation == translation,
                  ))
                    _modelTile(context, ref, model, state),
                ],
                if (state.model != null &&
                    state.translationModel != null &&
                    state.model!.source != state.translationModel!.source)
                  Text(context.l10n.local_captions_mismatch),
                if (state.error) ...[
                  Text(
                    context.l10n.local_captions_model_error,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton(
                      onPressed: notifier.refresh,
                      child: Text(context.l10n.common_retry),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _modelTile(
    BuildContext context,
    WidgetRef ref,
    LocalCaptionModel model,
    LocalCaptionSettings state,
  ) {
    final notifier = ref.read(localCaptionSettingsProvider.notifier);
    final installed = state.installed.contains(model.id);
    final selected =
        (model.isTranslation ? state.translation : state.selected) == model.id;
    final downloading = state.downloading == model.id;
    final busy = state.downloading != null || state.loading;
    final percent = NumberFormat.percentPattern(
      context.l10n.localeName,
    ).format(state.progress);
    return ListTile(
      key: ValueKey('caption-model-${model.id}'),
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        selected
            ? Icons.check_circle
            : installed
            ? Icons.circle_outlined
            : Icons.download_outlined,
      ),
      title: Text(localCaptionModelLabel(context, model)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.local_captions_size(
              NumberFormat(
                '0.0',
                context.l10n.localeName,
              ).format(model.bytes / 1000000),
              model.engine == 'whisper' ? 'MIT' : 'Apache-2.0',
            ),
          ),
          if (selected) Text(context.l10n.selected),
          if (downloading)
            LinearProgressIndicator(
              value: state.progress,
              semanticsLabel: context.l10n.common_download,
              semanticsValue: percent,
            ),
        ],
      ),
      onTap: installed && !busy ? () => notifier.select(model.id) : null,
      trailing: downloading
          ? IconButton(
              tooltip: context.l10n.common_cancel,
              onPressed: notifier.cancelDownload,
              icon: const Icon(Icons.close),
            )
          : installed
          ? PopupMenuButton<String>(
              tooltip: context.l10n.common_settings,
              onSelected: (value) async {
                if (value == 'select') {
                  await notifier.select(model.id);
                } else {
                  await ref.read(localCaptionsProvider.notifier).stop();
                  await notifier.delete(model);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'select',
                  enabled: !busy,
                  child: Text(context.l10n.local_captions_select),
                ),
                PopupMenuItem(
                  value: 'delete',
                  enabled: !busy,
                  child: Text(context.l10n.common_delete),
                ),
              ],
            )
          : IconButton(
              tooltip: context.l10n.common_download,
              onPressed: busy ? null : () => notifier.download(model),
              icon: const Icon(Icons.download),
            ),
    );
  }
}
