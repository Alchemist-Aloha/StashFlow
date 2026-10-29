import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../providers/local_captions_provider.dart';
import '../providers/video_player_provider.dart';
import 'local_caption_labels.dart';
import 'subtitle_presentation.dart';

/// Renders the same generated cue in inline, feed, fullscreen and PiP surfaces.
class GeneratedCaptionOverlay extends ConsumerWidget {
  const GeneratedCaptionOverlay({
    super.key,
    required this.player,
    this.presentation,
  });
  final Player player;

  /// Uses the video surface's exact padding, including transformed layouts.
  final SubtitleViewConfiguration? presentation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final captions = ref.watch(localCaptionsProvider);
    if (!identical(captions.player, player) ||
        captions.mode == LocalCaptionMode.off) {
      return const SizedBox.shrink();
    }
    final settings = ref.watch(playerStateProvider);
    final text = switch (captions.frame.status) {
      CaptionStatus.preparing => context.l10n.local_captions_preparing,
      CaptionStatus.failed => context.l10n.local_captions_failed,
      CaptionStatus.translationUnavailable =>
        context.l10n.local_captions_missing_pair(
          localCaptionLanguageLabel(context, captions.frame.language ?? 'und'),
          localCaptionLanguageLabel(
            context,
            captions.frame.outputLanguage ?? 'und',
          ),
        ),
      CaptionStatus.ready => captions.frame.text,
    };
    if (text.isEmpty) return const SizedBox.shrink();
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final subtitles =
              presentation ??
              subtitlePresentation(
                context,
                fontSize: settings.subtitleFontSize,
                textAlign: switch (settings.subtitleTextAlignment) {
                  'left' => TextAlign.left,
                  'right' => TextAlign.right,
                  _ => TextAlign.center,
                },
                bottomPadding:
                    constraints.maxHeight *
                    settings.subtitlePositionBottomRatio,
              );
          return Padding(
            padding: subtitles.padding,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                text,
                textAlign: subtitles.textAlign,
                style: subtitles.style,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        },
      ),
    );
  }
}
