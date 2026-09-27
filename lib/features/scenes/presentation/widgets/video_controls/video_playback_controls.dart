import 'package:flutter/material.dart';
import '../../../../../core/utils/l10n_extensions.dart';
import '../../../../../core/presentation/theme/app_theme.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../domain/entities/scene.dart';
import '../../../domain/entities/scene_title_utils.dart';
import 'cast_selection_sheet.dart';
import '../../providers/video_player_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/data/services/cast_service.dart';
import '../../../../../core/utils/pip_mode.dart';

/// Shared button treatment for controls over the video image.
ButtonStyle playerOverlayButtonStyle(BuildContext context) {
  final dimensions = context.dimensions;
  return IconButton.styleFrom(
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.white,
    disabledBackgroundColor: Colors.transparent,
    disabledForegroundColor: Colors.white54,
    padding: EdgeInsets.all(dimensions.spacingSmall / 2),
    minimumSize: Size.square(dimensions.buttonHeight),
    iconSize: 24 * dimensions.fontSizeFactor,
    shape: const CircleBorder(),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}

class VideoTransportControls extends StatelessWidget {
  const VideoTransportControls({
    super.key,
    required this.isPlaying,
    required this.isFullScreen,
    required this.previousScene,
    required this.nextScene,
    required this.onPlayPause,
    required this.onSkipPrevious,
    required this.onSkipNext,
    required this.onInteract,
  });

  final bool isPlaying;
  final bool isFullScreen;
  final Scene? previousScene;
  final Scene? nextScene;
  final VoidCallback onPlayPause;
  final VoidCallback onSkipPrevious;
  final VoidCallback onSkipNext;
  final VoidCallback onInteract;

  ButtonStyle _buttonStyle(BuildContext context, {bool emphasized = false}) {
    final dimensions = context.dimensions;
    final colorScheme = Theme.of(context).colorScheme;
    final size = emphasized
        ? dimensions.buttonHeight +
              (isFullScreen
                  ? dimensions.spacingMedium
                  : dimensions.spacingSmall)
        : dimensions.buttonHeight;

    return IconButton.styleFrom(
      backgroundColor: emphasized ? colorScheme.primary : Colors.transparent,
      foregroundColor: emphasized ? colorScheme.onPrimary : Colors.white,
      disabledBackgroundColor: Colors.transparent,
      disabledForegroundColor: Colors.white38,
      padding: EdgeInsets.zero,
      minimumSize: Size.square(size),
      shape: const CircleBorder(),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final compact = !isFullScreen;
    final scale = context.dimensions.fontSizeFactor;
    final gap = context.dimensions.spacingSmall;
    final hasQueueNavigation = previousScene != null || nextScene != null;

    return Container(
      key: const Key('video_transport_controls'),
      padding: EdgeInsets.all(context.dimensions.spacingSmall / 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasQueueNavigation) ...[
            IconButton(
              tooltip: context.l10n.common_skip_previous,
              style: _buttonStyle(context),
              iconSize: (compact ? 22.0 : 26.0) * scale,
              icon: const Icon(Icons.skip_previous_rounded),
              onPressed: previousScene == null
                  ? null
                  : () {
                      onSkipPrevious();
                      onInteract();
                    },
            ),
            SizedBox(width: gap),
          ],
          IconButton(
            key: const Key('video_play_pause_button'),
            tooltip: isPlaying
                ? context.l10n.common_pause
                : context.l10n.common_play,
            style: _buttonStyle(context, emphasized: true),
            iconSize: (compact ? 30.0 : 34.0) * scale,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                key: ValueKey(isPlaying),
              ),
            ),
            onPressed: () {
              onPlayPause();
              onInteract();
            },
          ),
          if (hasQueueNavigation) ...[
            SizedBox(width: gap),
            IconButton(
              tooltip: context.l10n.common_skip_next,
              style: _buttonStyle(context),
              iconSize: (compact ? 22.0 : 26.0) * scale,
              icon: const Icon(Icons.skip_next_rounded),
              onPressed: nextScene == null
                  ? null
                  : () {
                      onSkipNext();
                      onInteract();
                    },
            ),
          ],
        ],
      ),
    );
  }
}

class VideoPlaybackControls extends ConsumerWidget {
  const VideoPlaybackControls({
    super.key,
    required this.controller,
    required this.scene,
    required this.playbackSpeed,
    required this.isFullScreen,
    required this.onSubtitleSelected,
    required this.onSpeedSelected,
    required this.onFullScreenToggle,
    required this.enableNativePip,
    required this.onInteract,
    required this.desktopVolumeControl,
    required this.selectedSubtitleLanguage,
    required this.selectedSubtitleType,
    required this.onSpeedTap,
    required this.isSpeedSliderVisible,
    this.onStopCast,
  });

  final VideoController controller;
  final Scene scene;
  final double playbackSpeed;
  final bool isFullScreen;
  final ValueChanged<String?> onSubtitleSelected;
  final ValueChanged<double> onSpeedSelected;
  final VoidCallback? onFullScreenToggle;
  final bool enableNativePip;
  final VoidCallback onInteract;
  final Widget? desktopVolumeControl;
  final String? selectedSubtitleLanguage;
  final String? selectedSubtitleType;
  final VoidCallback onSpeedTap;
  final bool isSpeedSliderVisible;
  final VoidCallback? onStopCast;

  static const _playbackSpeeds = <double>[
    0.25,
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    2.0,
    3.0,
  ];

  String _formatSpeed(double speed) {
    if (speed == speed.toInt()) {
      return '${speed.toInt()}x';
    }
    String s = speed.toStringAsFixed(2);
    if (s.endsWith('0')) {
      s = s.substring(0, s.length - 1);
    }
    return '${s}x';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = context.dimensions.fontSizeFactor;
    final controlIconSize = 24.0 * scale;
    final buttonMinSize = context.dimensions.buttonHeight;
    final buttonGap = context.dimensions.spacingSmall;
    final colorScheme = Theme.of(context).colorScheme;
    final canSelectSubtitles = scene.captions.isNotEmpty;
    final castState = ref.watch(castServiceProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (canSelectSubtitles)
                      PopupMenuButton<String?>(
                        tooltip: context.l10n.common_select_subtitle,
                        padding: EdgeInsets.zero,
                        initialValue: selectedSubtitleLanguage,
                        color: colorScheme.surfaceContainerHigh,
                        surfaceTintColor: colorScheme.surfaceTint,
                        onSelected: (value) {
                          onSubtitleSelected(value);
                          onInteract();
                        },
                        itemBuilder: (context) {
                          final items = <PopupMenuEntry<String?>>[
                            PopupMenuItem<String?>(
                              value: 'none',
                              child: Row(
                                children: [
                                  Icon(
                                    (selectedSubtitleLanguage == null ||
                                            selectedSubtitleLanguage == 'none')
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    size: 16,
                                    color:
                                        (selectedSubtitleLanguage == null ||
                                            selectedSubtitleLanguage == 'none')
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                  Text(
                                    context.l10n.common_none,
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ];

                          for (final c in scene.captions) {
                            final selectedLang = selectedSubtitleLanguage ?? '';
                            final selectedType = selectedSubtitleType ?? '';
                            final captionLang = c.languageCode;
                            final captionType = c.captionType;
                            final isUnknownLangSelection =
                                (selectedLang.isEmpty ||
                                    selectedLang == '00') &&
                                (captionLang.isEmpty || captionLang == '00');
                            final isSelected =
                                (selectedLang == captionLang ||
                                    isUnknownLangSelection) &&
                                (selectedType == captionType ||
                                    (selectedType.isEmpty &&
                                        isUnknownLangSelection));

                            final label =
                                c.languageCode == '00' || c.languageCode.isEmpty
                                ? '${context.l10n.common_unknown} (${c.captionType})'
                                : '${c.languageCode.toUpperCase()} (${c.captionType})';

                            items.add(
                              PopupMenuItem<String?>(
                                value: '${c.languageCode}:${c.captionType}',
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      size: 16,
                                      color: isSelected
                                          ? colorScheme.primary
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                    Text(
                                      label,
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return items;
                        },
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: buttonMinSize,
                            minHeight: buttonMinSize,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.subtitles_rounded,
                              size: controlIconSize,
                              color:
                                  selectedSubtitleLanguage != null &&
                                      selectedSubtitleLanguage != 'none'
                                  ? colorScheme.primary
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    if (canSelectSubtitles) SizedBox(width: buttonGap),
                    PopupMenuButton<double>(
                      tooltip: context.l10n.common_playback_speed,
                      initialValue: playbackSpeed,
                      color: colorScheme.surfaceContainerHigh,
                      surfaceTintColor: colorScheme.surfaceTint,
                      onSelected: (speed) {
                        onSpeedSelected(speed);
                        onInteract();
                      },
                      itemBuilder: (context) {
                        return _playbackSpeeds
                            .map(
                              (speed) => PopupMenuItem<double>(
                                value: speed,
                                child: Row(
                                  children: [
                                    Icon(
                                      speed == playbackSpeed
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      size: 16,
                                      color: speed == playbackSpeed
                                          ? colorScheme.primary
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                    Text(
                                      _formatSpeed(speed),
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList();
                      },
                      child: Semantics(
                        button: true,
                        label: context.l10n.common_playback_speed,
                        child: Tooltip(
                          message: context.l10n.common_playback_speed,
                          child: Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.hardEdge,
                            child: InkWell(
                              onTap: onSpeedTap,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: buttonMinSize,
                                  minHeight: buttonMinSize,
                                ),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(999),
                                    border: isSpeedSliderVisible
                                        ? Border.all(
                                            color: colorScheme.primary,
                                            width: 1.5,
                                          )
                                        : null,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Center(
                                      child: Text(
                                        _formatSpeed(playbackSpeed),
                                        style: context.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: isSpeedSliderVisible
                                                  ? colorScheme.primary
                                                  : Colors.white,
                                              fontSize: context.fontSizes.small,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: buttonGap),
                    if (desktopVolumeControl != null) ...[
                      desktopVolumeControl!,
                      SizedBox(width: buttonGap),
                    ],
                    if (castState.isCasting)
                      IconButton(
                        tooltip: context.l10n.cast_stop_casting,
                        style: playerOverlayButtonStyle(context),
                        icon: Icon(
                          Icons.cast_connected_rounded,
                          size: controlIconSize,
                          color: colorScheme.primary,
                        ),
                        onPressed: () {
                          onInteract();
                          onStopCast?.call();
                        },
                      )
                    else
                      IconButton(
                        tooltip: context.l10n.cast_cast,
                        style: playerOverlayButtonStyle(context),
                        icon: Icon(Icons.cast_rounded, size: controlIconSize),
                        onPressed: () {
                          onInteract();
                          showModalBottomSheet<void>(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (context) => CastSelectionSheet(
                              videoUrl:
                                  controller
                                      .player
                                      .state
                                      .playlist
                                      .medias
                                      .firstOrNull
                                      ?.uri ??
                                  '',
                              title: scene.displayTitle,
                            ),
                          );
                        },
                      ),
                    SizedBox(width: buttonGap),
                    if (enableNativePip && PipMode.isSupported) ...[
                      IconButton(
                        tooltip: context.l10n.common_pip,
                        style: playerOverlayButtonStyle(context),
                        icon: Icon(
                          Icons.picture_in_picture_alt_outlined,
                          size: controlIconSize,
                        ),
                        onPressed: () async {
                          final w = controller.player.state.width;
                          final h = controller.player.state.height;
                          final r = (w != null && h != null && h > 0)
                              ? w / h
                              : 16 / 9;
                          await ref
                              .read(playerStateProvider.notifier)
                              .requestEnterPip(aspectRatio: r);
                          onInteract();
                        },
                      ),
                      SizedBox(width: buttonGap),
                    ],
                    GestureDetector(
                      onTap: () {}, // Consume tap to prevent propagation
                      child: IconButton(
                        key: const Key('video_fullscreen_button'),
                        tooltip: context.l10n.common_toggle_fullscreen,
                        style: playerOverlayButtonStyle(context),
                        icon: Icon(
                          isFullScreen
                              ? Icons.fullscreen_exit_rounded
                              : Icons.fullscreen_rounded,
                          size: controlIconSize,
                        ),
                        onPressed: () {
                          onFullScreenToggle?.call();
                          onInteract();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
