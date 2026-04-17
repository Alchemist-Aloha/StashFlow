import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../../core/utils/pip_mode.dart';
import '../../../domain/entities/scene.dart';

class VideoPlaybackControls extends StatelessWidget {
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
    required this.formattedCurrentTime,
    required this.formattedDuration,
    required this.onSpeedTap,
    required this.isSpeedSliderVisible,
  });

  final VideoPlayerController controller;
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
  final String formattedCurrentTime;
  final String formattedDuration;
  final VoidCallback onSpeedTap;
  final bool isSpeedSliderVisible;

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
      backgroundColor: colorScheme.surfaceContainerHigh.withValues(alpha: 0.62),
      foregroundColor: colorScheme.onSurface,
      disabledBackgroundColor: colorScheme.surfaceContainerLow.withValues(
        alpha: 0.5,
      ),
      disabledForegroundColor: colorScheme.onSurfaceVariant.withValues(
        alpha: 0.55,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(8),
      minimumSize: const Size(38, 38),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        IconButton(
          tooltip: isPlaying ? 'Pause' : 'Play',
          style: _controlButtonStyle(colorScheme),
          iconSize: 20,
          icon: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          ),
          onPressed: () {
            onPlayPause();
            onInteract();
          },
        ),
        if (nextScene != null && !isFullScreen) ...[
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Skip Next',
            style: _controlButtonStyle(colorScheme),
            iconSize: 20,
            icon: const Icon(Icons.skip_next_rounded),
            onPressed: () {
              onSkipNext();
              onInteract();
            },
          ),
        ],
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$formattedCurrentTime / $formattedDuration',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        if (scene.captions.isNotEmpty)
          PopupMenuButton<String?>(
            tooltip: 'Select subtitle',
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
                        color: (selectedSubtitleLanguage == null ||
                                selectedSubtitleLanguage == 'none')
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'None',
                        style: TextStyle(color: colorScheme.onSurface),
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
                    (selectedLang.isEmpty || selectedLang == '00') &&
                        (captionLang.isEmpty || captionLang == '00');
                final isSelected =
                    (selectedLang == captionLang || isUnknownLangSelection) &&
                        (selectedType == captionType ||
                            (selectedType.isEmpty && isUnknownLangSelection));

                final label = c.languageCode == '00' || c.languageCode.isEmpty
                    ? 'Unknown (${c.captionType})'
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
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return items;
            },
          ),
        const SizedBox(width: 8),
        PopupMenuButton<double>(
          tooltip: 'Playback speed',
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
                            const SizedBox(width: 8),
                            Text(
                              _formatSpeed(speed),
                              style: TextStyle(color: colorScheme.onSurface),
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
              constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.62),
                borderRadius: BorderRadius.circular(10),
                border: isSpeedSliderVisible
                    ? Border.all(color: colorScheme.primary, width: 1.5)
                    : null,
              ),
              child: Text(
                _formatSpeed(playbackSpeed),
                style: TextStyle(
                  color: isSpeedSliderVisible
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        if (desktopVolumeControl != null) ...[
          const SizedBox(width: 8),
          desktopVolumeControl!,
        ],
        const SizedBox(width: 6),
        if (enableNativePip && !kIsWeb && Platform.isAndroid)
          IconButton(
            tooltip: 'Picture-in-Picture',
            style: _controlButtonStyle(colorScheme),
            icon: const Icon(Icons.picture_in_picture_alt_outlined),
            onPressed: () async {
              if (!isFullScreen) {
                onFullScreenToggle?.call();
                await Future.delayed(const Duration(milliseconds: 150));
              }
              await PipMode.enterIfAvailable(
                aspectRatio: controller.value.aspectRatio,
              );
              onInteract();
            },
          ),
        GestureDetector(
          onTap: () {}, // Consume tap to prevent propagation
          child: IconButton(
            tooltip: 'Toggle Fullscreen',
            style: _controlButtonStyle(colorScheme),
            icon: Icon(
              isFullScreen
                  ? Icons.fullscreen_exit_rounded
                  : Icons.fullscreen_rounded,
            ),
            onPressed: () {
              onFullScreenToggle?.call();
              onInteract();
            },
          ),
        ),
      ],
    );
  }
}
