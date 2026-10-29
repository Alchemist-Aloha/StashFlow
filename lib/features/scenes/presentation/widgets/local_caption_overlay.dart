import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../providers/local_captions_provider.dart';
import '../providers/video_player_provider.dart';

/// Renders the same generated cue in inline, feed, fullscreen and PiP surfaces.
class GeneratedCaptionOverlay extends ConsumerWidget {
  const GeneratedCaptionOverlay({super.key, required this.player});
  final Player player;

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
      CaptionStatus.ready => captions.frame.text,
    };
    if (text.isEmpty) return const SizedBox.shrink();
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              context.dimensions.spacingMedium,
              0,
              context.dimensions.spacingMedium,
              constraints.maxHeight * settings.subtitlePositionBottomRatio,
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                text,
                textAlign: switch (settings.subtitleTextAlignment) {
                  'left' => TextAlign.left,
                  'right' => TextAlign.right,
                  _ => TextAlign.center,
                },
                style: TextStyle(
                  color: Colors.white,
                  backgroundColor: Colors.black87,
                  fontSize:
                      settings.subtitleFontSize *
                      context.dimensions.fontSizeFactor,
                ),
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
