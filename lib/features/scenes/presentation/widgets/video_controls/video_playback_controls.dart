import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../../core/utils/l10n_extensions.dart';
import '../../../../../core/presentation/theme/app_theme.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../../core/utils/pip_mode.dart';
import '../../../domain/entities/scene.dart';
import '../../../domain/entities/scene_title_utils.dart';
import 'cast_selection_sheet.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/data/services/cast_service.dart';

class VideoPlaybackControls extends ConsumerWidget {
  const VideoPlaybackControls({
    super.key,
    required this.controller,
    required this.scene,
    required this.isPlaying,
    required this.playbackSpeed,
    required this.nextScene,
    required this.isFullScreen,
    required this.onPlayPause,
    required this.onSkipNext,
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
  final bool isPlaying;
  final double playbackSpeed;
  final Scene? nextScene;
  final bool isFullScreen;
  final VoidCallback onPlayPause;
  final VoidCallback onSkipNext;
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

  ButtonStyle _controlButtonStyle(ColorScheme colorScheme) {
    return IconButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      disabledBackgroundColor: Colors.transparent,
      disabledForegroundColor: colorScheme.onSurfaceVariant.withValues(
        alpha: 0.55,
      ),
      padding: const EdgeInsets.all(8),
      minimumSize: const Size(32, 32),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: isPlaying ? 'Pause' : 'Play',
                      style: _controlButtonStyle(colorScheme),
                      iconSize: 20,
                      icon: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      onPressed: () {
                        onPlayPause();
                        onInteract();
                      },
                    ),
                    if (nextScene != null && !isFullScreen) ...[
                      IconButton(
                        tooltip: context.l10n.common_skip_next,
                        style: _controlButtonStyle(colorScheme),
                        iconSize: 20,
                        icon: const Icon(Icons.skip_next_rounded),
                        onPressed: () {
                          onSkipNext();
                          onInteract();
                        },
                      ),
                    ],
                  ],
                ),
                const SizedBox(
                  width: 4,
                ), // Padding between left and right groups
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (canSelectSubtitles)
                      PopupMenuButton<String?>(
                        tooltip: context.l10n.common_select_subtitle,
                        icon: Icon(
                          Icons.subtitles_rounded,
                          size: 20,
                          color:
                              selectedSubtitleLanguage != null &&
                                  selectedSubtitleLanguage != 'none'
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                        style: _controlButtonStyle(colorScheme),
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
                      ),
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
                      child: GestureDetector(
                        onTap: onSpeedTap,
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: isSpeedSliderVisible
                                ? Border.all(
                                    color: colorScheme.primary,
                                    width: 1.5,
                                  )
                                : null,
                          ),
                          child: Text(
                            _formatSpeed(playbackSpeed),
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: isSpeedSliderVisible
                                  ? colorScheme.primary
                                  : colorScheme.onSurface,
                              fontSize: context.fontSizes.small,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (desktopVolumeControl != null) ...[
                      desktopVolumeControl!,
                    ],
                    if (castState.isCasting)
                      IconButton(
                        tooltip: 'Stop Casting',
                        style: _controlButtonStyle(colorScheme),
                        icon: Icon(
                          Icons.cast_connected_rounded,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        onPressed: () {
                          onInteract();
                          onStopCast?.call();
                        },
                      )
                    else
                      IconButton(
                        tooltip: 'Cast',
                        style: _controlButtonStyle(colorScheme),
                        icon: const Icon(Icons.cast_rounded, size: 20),
                        onPressed: () {
                          onInteract();
                          showModalBottomSheet(
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
                    if (enableNativePip && !kIsWeb && Platform.isAndroid) ...[
                      IconButton(
                        tooltip: context.l10n.common_pip,
                        style: _controlButtonStyle(colorScheme),
                        icon: const Icon(
                          Icons.picture_in_picture_alt_outlined,
                          size: 20,
                        ),
                        onPressed: () async {
                          if (!isFullScreen) {
                            onFullScreenToggle?.call();
                            await Future.delayed(
                              const Duration(milliseconds: 150),
                            );
                          }
                          final w = controller.player.state.width;
                          final h = controller.player.state.height;
                          final r = (w != null && h != null && h > 0)
                              ? w / h
                              : 16 / 9;
                          await PipMode.enterIfAvailable(aspectRatio: r);
                          onInteract();
                        },
                      ),
                    ],
                    GestureDetector(
                      onTap: () {}, // Consume tap to prevent propagation
                      child: IconButton(
                        tooltip: context.l10n.common_toggle_fullscreen,
                        style: _controlButtonStyle(colorScheme),
                        icon: Icon(
                          isFullScreen
                              ? Icons.fullscreen_exit_rounded
                              : Icons.fullscreen_rounded,
                          size: 20,
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
