import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../scenes/data/local_captions/local_caption_model.dart';
import '../../../scenes/presentation/providers/local_caption_settings.dart';
import '../../../scenes/presentation/providers/local_captions_provider.dart';
import '../../../scenes/presentation/widgets/local_caption_labels.dart';
import 'caption_model_picker.dart';
import 'settings_page_shell.dart';

/// Searchable live catalogs plus offline management of installed snapshots.
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
                Text(context.l10n.local_captions_catalog_help),
                SizedBox(height: context.dimensions.spacingLarge),
                if (state.loading) const LinearProgressIndicator(),
                const CaptionModelPicker(translation: false),
                SizedBox(height: context.dimensions.spacingLarge),
                const CaptionModelPicker(translation: true),
                if (state.downloaded.isNotEmpty)
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    initiallyExpanded: true,
                    title: Text(context.l10n.local_captions_downloaded),
                    children: [
                      for (final model in state.downloaded)
                        _tile(context, ref, model, state),
                    ],
                  ),
                if (state.model != null &&
                    state.translationModel != null &&
                    !state.canTranslate)
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

  Widget _tile(
    BuildContext context,
    WidgetRef ref,
    LocalCaptionModel model,
    LocalCaptionSettings state,
  ) {
    final selected =
        (model.isTranslation ? state.translation : state.selected) == model.id;
    final busy = state.downloading != null || state.loading;
    final notifier = ref.read(localCaptionSettingsProvider.notifier);
    return ListTile(
      key: ValueKey('caption-model-${model.id}'),
      contentPadding: EdgeInsets.zero,
      leading: Icon(selected ? Icons.check_circle : Icons.circle_outlined),
      title: Text(localCaptionModelLabel(context, model)),
      subtitle: Text(model.repository),
      onTap: busy ? null : () => notifier.select(model.id),
      trailing: PopupMenuButton<String>(
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
      ),
    );
  }
}
