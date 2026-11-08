import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../../../../core/data/services/cast_service.dart';
import '../../../../../core/presentation/theme/app_theme.dart';
import '../../../../../core/utils/l10n_extensions.dart';
import '../../../domain/entities/scene.dart';
import '../../providers/local_caption_settings.dart';
import '../../providers/local_captions_provider.dart';
import '../../providers/video_player_provider.dart';
import 'caption_tuning_dialog.dart';

/// Shared subtitle menu, including scenes with no server-provided captions.
class SceneSubtitleMenu extends ConsumerWidget {
  const SceneSubtitleMenu({
    super.key,
    required this.controller,
    required this.scene,
    this.onSubtitleSelected,
    this.onInteract,
  });
  final VideoController controller;
  final Scene scene;
  final ValueChanged<String?>? onSubtitleSelected;
  final VoidCallback? onInteract;

  void _openSettings(BuildContext context, WidgetRef ref) {
    if (!context.mounted) return;
    final router = GoRouter.of(context);
    if (ref.read(playerStateProvider).isFullScreen) {
      final player = ref.read(playerStateProvider.notifier);
      player.syncBackgroundToActiveScene(context);
      player.requestExitFullscreen();
    }
    unawaited(router.push('/settings/playback'));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(playerStateProvider);
    final generated = ref.watch(localCaptionsProvider);
    final casting = ref.watch(castServiceProvider.select((s) => s.isCasting));
    final ownsPlayer =
        identical(playback.player, controller.player) &&
        playback.activeScene?.id == scene.id;
    final mode = identical(generated.player, controller.player)
        ? generated.mode
        : LocalCaptionMode.off;
    final enabled = ownsPlayer && !casting && localCaptionsSupported;
    final nativeLanguage = playback.selectedSubtitleLanguage;
    final hasNative = nativeLanguage != null && nativeLanguage != 'none';
    final theme = Theme.of(context).colorScheme;
    return PopupMenuButton<String>(
      tooltip: context.l10n.common_select_subtitle,
      color: theme.surfaceContainerHigh,
      onOpened: onInteract,
      onSelected: (value) async {
        onInteract?.call();
        final notifier = ref.read(localCaptionsProvider.notifier);
        if (value == '__transcribe') {
          final current = ref.read(playerStateProvider);
          if (current.activeScene?.id != scene.id ||
              !identical(current.player, controller.player)) {
            return;
          }
          final draft = await showCaptionTuningDialog(context);
          if (draft == null || !context.mounted) return;
          if (draft.manageModels) {
            _openSettings(context, ref);
            return;
          }
          final active = ref.read(playerStateProvider);
          if (active.activeScene?.id != scene.id ||
              !identical(active.player, controller.player)) {
            return;
          }
          await ref
              .read(localCaptionSettingsProvider.notifier)
              .configure(
                draft.speechId!,
                draft.options,
                translationId: draft.mode == LocalCaptionMode.translate
                    ? draft.translationId
                    : null,
                automaticTranslation:
                    draft.mode == LocalCaptionMode.translate &&
                    draft.translationId == null,
              );
          if (!context.mounted) return;
          final afterSave = ref.read(playerStateProvider);
          if (afterSave.activeScene?.id != scene.id ||
              !identical(afterSave.player, controller.player)) {
            return;
          }
          await notifier.setMode(draft.mode);
        } else {
          await notifier.stop();
          if (!context.mounted) return;
          final current = ref.read(playerStateProvider);
          if (current.activeScene?.id != scene.id ||
              !identical(current.player, controller.player)) {
            return;
          }
          if (onSubtitleSelected != null) {
            onSubtitleSelected!(value);
          } else {
            final parts = value.split(':');
            await ref
                .read(playerStateProvider.notifier)
                .setSubtitle(
                  parts.first,
                  captionType: parts.length > 1 ? parts[1] : null,
                );
          }
        }
      },
      itemBuilder: (_) => [
        CheckedPopupMenuItem(
          value: 'none',
          checked: mode == LocalCaptionMode.off && !hasNative,
          child: Text(context.l10n.common_none),
        ),
        for (final caption in scene.captions)
          CheckedPopupMenuItem(
            value: '${caption.languageCode}:${caption.captionType}',
            checked:
                mode == LocalCaptionMode.off &&
                (nativeLanguage == caption.languageCode ||
                    ((nativeLanguage == null ||
                            nativeLanguage.isEmpty ||
                            nativeLanguage == '00') &&
                        (caption.languageCode.isEmpty ||
                            caption.languageCode == '00'))) &&
                (playback.selectedSubtitleType == caption.captionType ||
                    ((playback.selectedSubtitleType?.isEmpty ?? true) &&
                        (caption.languageCode.isEmpty ||
                            caption.languageCode == '00'))),
            child: Text(
              '${caption.languageCode.isEmpty || caption.languageCode == '00' ? context.l10n.common_unknown : caption.languageCode.toUpperCase()} (${caption.captionType})',
            ),
          ),
        const PopupMenuDivider(),
        CheckedPopupMenuItem(
          value: '__transcribe',
          checked: mode != LocalCaptionMode.off,
          enabled: enabled,
          child: Text(context.l10n.local_captions_transcribe),
        ),
        if (!localCaptionsSupported)
          PopupMenuItem(
            enabled: false,
            child: Text(context.l10n.local_captions_unsupported),
          ),
      ],
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: context.dimensions.buttonHeight,
          minHeight: context.dimensions.buttonHeight,
        ),
        child: Icon(
          Icons.subtitles_rounded,
          size: 24 * context.dimensions.fontSizeFactor,
          color: mode != LocalCaptionMode.off || hasNative
              ? theme.primary
              : Colors.white,
        ),
      ),
    );
  }
}
