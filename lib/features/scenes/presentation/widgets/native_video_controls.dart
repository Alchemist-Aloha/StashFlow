import 'dart:async';
import 'dart:math' as math;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'video_controls/video_progress_bar.dart';
import 'video_controls/video_playback_controls.dart';
import '../../../../core/presentation/providers/desktop_capabilities_provider.dart';
import '../../../../core/presentation/providers/desktop_settings_provider.dart';
import '../../../../core/presentation/providers/keybinds_provider.dart';
import '../../../../core/utils/pip_mode.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/utils/app_log_store.dart';
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_title_utils.dart';
import '../providers/video_player_provider.dart';
import '../providers/playback_queue_provider.dart';
import 'scrubbing_preview.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';

class NativeVideoControls extends ConsumerStatefulWidget {
  const NativeVideoControls({
    required this.controller,
    required this.useDoubleTapSeek,
    required this.enableNativePip,
    this.onFullScreenToggle,
    required this.scene,
    super.key,
  });

  final VideoPlayerController controller;
  final bool useDoubleTapSeek;
  final bool enableNativePip;
  final VoidCallback? onFullScreenToggle;
  final Scene scene;

  @override
  ConsumerState<NativeVideoControls> createState() =>
      _NativeVideoControlsState();
}

class _NativeVideoControlsState extends ConsumerState<NativeVideoControls>
    with WidgetsBindingObserver {
  static const _controlsAutoHideDelay = Duration(milliseconds: 1000);
  static const _gestureSeekSeconds = 10;
  static const _dragSeekSensitivity = 0.30;
  static const _dragSeekCurveExponent = 1.6;

  bool _isScrubbing = false;
  double _scrubMs = 0;
  bool _controlsVisible = true;
  bool _wasPlaying = false;
  bool _wasPlayingBeforeScrub = false;
  bool _showVolumeSlider = false;
  bool _showSpeedSlider = false;
  Timer? _hideControlsTimer;
  Duration? _dragSeekStartPosition;
  Duration? _dragSeekTarget;
  double _dragSeekAccumulatedDx = 0;
  bool _dragSeekShouldResumePlayback = false;
  int? _seekFeedbackSeconds;
  Timer? _seekFeedbackTimer;
  bool _volumeOverlayVisible = false;
  Timer? _volumeOverlayTimer;
  ProviderSubscription<DesktopSettings>? _desktopSettingsSubscription;

  @override
  void initState() {
    super.initState();
    AppLogStore.instance.add(
      'NativeVideoControls init scene=${widget.scene.id}',
      source: 'NativeVideoControls',
    );
    WidgetsBinding.instance.addObserver(this);
    widget.controller.addListener(_onVideoTick);
    _wasPlaying = widget.controller.value.isPlaying;
    if (_wasPlaying) {
      _scheduleAutoHide();
    }

    if (ref.read(desktopCapabilitiesProvider)) {
      _desktopSettingsSubscription = ref.listenManual<DesktopSettings>(
        desktopSettingsProvider,
        (previous, next) {
          if (previous?.volume != next.volume ||
              previous?.isMuted != next.isMuted) {
            _showVolumeOverlay();
          }
        },
      );
    }
  }

  @override
  void didUpdateWidget(covariant NativeVideoControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      AppLogStore.instance.add(
        'NativeVideoControls didUpdateWidget controllerChange scene=${widget.scene.id}',
        source: 'NativeVideoControls',
      );
      oldWidget.controller.removeListener(_onVideoTick);
      widget.controller.addListener(_onVideoTick);
    }
  }

  @override
  void dispose() {
    AppLogStore.instance.add(
      'NativeVideoControls dispose scene=${widget.scene.id}',
      source: 'NativeVideoControls',
    );
    WidgetsBinding.instance.removeObserver(this);
    _cancelAutoHide();
    _seekFeedbackTimer?.cancel();
    _volumeOverlayTimer?.cancel();
    _desktopSettingsSubscription?.close();
    widget.controller.removeListener(_onVideoTick);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.enableNativePip || kIsWeb || !Platform.isAndroid) return;
    if (state != AppLifecycleState.paused) return;

    final controller = widget.controller;
    if (!controller.value.isPlaying) return;

    final isFullScreen = ref.read(playerStateProvider).isFullScreen;
    if (!isFullScreen) return;

    unawaited(
      PipMode.enterIfAvailable(aspectRatio: controller.value.aspectRatio),
    );
  }

  void _onVideoTick() {
    if (!mounted) return;

    final isActive =
        ref.read(playerStateProvider).activeScene?.id == widget.scene.id;
    if (!isActive) return;

    final isPlaying = widget.controller.value.isPlaying;
    if (isPlaying != _wasPlaying) {
      _wasPlaying = isPlaying;
      if (isPlaying) {
        _scheduleAutoHide();
      } else {
        _cancelAutoHide();
        setState(() => _controlsVisible = true);
      }
    }

    if (_isScrubbing) return;
    setState(() {});
  }

  void _cancelAutoHide() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = null;
  }

  void _scheduleAutoHide() {
    _cancelAutoHide();
    final isPlaying = widget.controller.value.isPlaying;
    if (!isPlaying || _isScrubbing) return;

    _hideControlsTimer = Timer(_controlsAutoHideDelay, () {
      if (!mounted) return;
      final stillPlaying = widget.controller.value.isPlaying;
      if (!stillPlaying || _isScrubbing || !_controlsVisible) return;
      setState(() => _controlsVisible = false);
    });
  }

  void _toggleControls() {
    setState(() {
      _controlsVisible = !_controlsVisible;
    });
    if (_controlsVisible) {
      _scheduleAutoHide();
    } else {
      _cancelAutoHide();
    }
  }

  void _showControlsTemporarily() {
    if (!mounted) return;
    if (!_controlsVisible) {
      setState(() => _controlsVisible = true);
    }
    _scheduleAutoHide();
  }

  void _seekRelativeSeconds(int seconds) {
    if (!widget.controller.value.isInitialized) return;
    final current = widget.controller.value.position;
    final duration = widget.controller.value.duration;
    final wasPlaying = widget.controller.value.isPlaying;
    var target = current + Duration(seconds: seconds);
    if (target < Duration.zero) target = Duration.zero;
    if (target > duration) target = duration;
    unawaited(_seekToKeepingPlayback(target, keepPlayingAfterSeek: wasPlaying));
    _showSeekFeedback(seconds, transient: true);
  }

  Future<void> _seekToKeepingPlayback(
    Duration target, {
    required bool keepPlayingAfterSeek,
  }) async {
    await widget.controller.seekTo(target);
    if (!mounted || !keepPlayingAfterSeek) return;
    if (!widget.controller.value.isPlaying) {
      await widget.controller.play();
    }
  }

  void _showSeekFeedback(int seconds, {bool transient = false}) {
    if (!mounted) return;
    _seekFeedbackTimer?.cancel();

    if (_seekFeedbackSeconds != seconds) {
      setState(() => _seekFeedbackSeconds = seconds);
    } else if (_seekFeedbackSeconds == null) {
      setState(() => _seekFeedbackSeconds = seconds);
    }

    if (transient) {
      _seekFeedbackTimer = Timer(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() => _seekFeedbackSeconds = null);
      });
    }
  }

  void _beginDragSeek() {
    final isActive =
        ref.read(playerStateProvider).activeScene?.id == widget.scene.id;
    if (!isActive) return;

    if (!widget.controller.value.isInitialized) return;
    _dragSeekStartPosition = widget.controller.value.position;
    _dragSeekTarget = null;
    _dragSeekAccumulatedDx = 0;
    _dragSeekShouldResumePlayback = widget.controller.value.isPlaying;
    _seekFeedbackTimer?.cancel();

    AppLogStore.instance.add(
      'NativeVideoControls beginDragSeek scene=${widget.scene.id}',
      source: 'NativeVideoControls',
    );
  }

  void _updateDragSeek(DragUpdateDetails details, double dragAreaWidth) {
    final isActive =
        ref.read(playerStateProvider).activeScene?.id == widget.scene.id;
    if (!isActive) return;

    final startPosition = _dragSeekStartPosition;
    if (!widget.controller.value.isInitialized || startPosition == null) return;
    if (dragAreaWidth <= 0) return;

    final duration = widget.controller.value.duration;
    if (duration <= Duration.zero) return;

    _dragSeekAccumulatedDx += details.primaryDelta ?? 0;
    final linearDragRatio = _dragSeekAccumulatedDx / dragAreaWidth;
    final curvedMagnitude = math
        .pow(linearDragRatio.abs(), _dragSeekCurveExponent)
        .toDouble();
    final curvedDragRatio = linearDragRatio.isNegative
        ? -curvedMagnitude
        : curvedMagnitude;

    final deltaMs =
        curvedDragRatio * duration.inMilliseconds * _dragSeekSensitivity;
    final unclampedTargetMs = startPosition.inMilliseconds + deltaMs;
    final targetMs = unclampedTargetMs.clamp(
      0,
      duration.inMilliseconds.toDouble(),
    );

    _dragSeekTarget = Duration(milliseconds: targetMs.round());

    final signedDeltaSeconds =
        ((_dragSeekTarget!.inMilliseconds - startPosition.inMilliseconds) /
                1000)
            .round();
    _showSeekFeedback(signedDeltaSeconds);
    setState(() {});
  }

  void _endDragSeek() {
    if (_dragSeekTarget != null) {
      unawaited(
        _seekToKeepingPlayback(
          _dragSeekTarget!,
          keepPlayingAfterSeek: _dragSeekShouldResumePlayback,
        ),
      );
    } else if (_dragSeekShouldResumePlayback &&
        !widget.controller.value.isPlaying) {
      unawaited(widget.controller.play());
    }

    _seekFeedbackTimer?.cancel();
    _seekFeedbackTimer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _seekFeedbackSeconds = null);
    });

    _dragSeekStartPosition = null;
    _dragSeekTarget = null;
    _dragSeekAccumulatedDx = 0;
    _dragSeekShouldResumePlayback = false;
  }

  void _togglePlay() {
    if (widget.controller.value.isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
    }
    _showControlsTemporarily();
  }

  void _playNext() {
    final queue = ref.read(playbackQueueProvider.notifier);
    final next = queue.getNextScene();
    if (next != null) {
      queue.playNext();
      if (mounted) {
        GoRouter.of(context).pushReplacement('/scenes/scene/${next.id}');
      }
    }
  }

  void _playPrevious() {
    final queue = ref.read(playbackQueueProvider.notifier);
    final prev = queue.getPreviousScene();
    if (prev != null) {
      queue.playPrevious();
      if (mounted) {
        GoRouter.of(context).pushReplacement('/scenes/scene/${prev.id}');
      }
    }
  }

  String _format(Duration d) {
    final totalSeconds = d.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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

  Widget _buildSeekFeedbackOverlay(ColorScheme colorScheme) {
    final seconds = _seekFeedbackSeconds;
    final isVisible = seconds != null;
    final effectiveSeconds = seconds ?? 0;
    final isForward = effectiveSeconds > 0;
    final isBackward = effectiveSeconds < 0;

    final icon = isForward
        ? Icons.fast_forward_rounded
        : isBackward
        ? Icons.fast_rewind_rounded
        : Icons.drag_indicator_rounded;
    final label = isForward
        ? '+${effectiveSeconds}s'
        : isBackward
        ? '${effectiveSeconds}s'
        : '0s';

    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: isVisible ? 1 : 0,
        duration: const Duration(milliseconds: 170),
        curve: Curves.easeOutCubic,
        child: AnimatedScale(
          scale: isVisible ? 1 : 0.94,
          duration: const Duration(milliseconds: 170),
          curve: Curves.easeOutCubic,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: ShapeDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.92,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.65),
                ),
              ),
              shadows: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopVolumeControl(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    final desktopSettings = ref.watch(desktopSettingsProvider);
    final isMuted = desktopSettings.isMuted;
    final volume = desktopSettings.volume;

    IconData iconData = Icons.volume_up_rounded;
    if (isMuted || volume == 0) {
      iconData = Icons.volume_off_rounded;
    } else if (volume < 0.5) {
      iconData = Icons.volume_down_rounded;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _showVolumeSlider = true),
      onExit: (_) => setState(() => _showVolumeSlider = false),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: isMuted ? 'Unmute' : 'Mute',
            style: _controlButtonStyle(colorScheme),
            iconSize: 20,
            icon: Icon(iconData),
            onPressed: () {
              ref.read(playerStateProvider.notifier).toggleMute();
              _showControlsTemporarily();
            },
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _showVolumeSlider ? 100 : 0,
            curve: Curves.easeInOut,
            child: Visibility(
              visible: _showVolumeSlider,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 12,
                  ),
                  activeTrackColor: colorScheme.primary,
                  inactiveTrackColor: colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.25,
                  ),
                  thumbColor: colorScheme.primary,
                ),
                child: Slider(
                  value: volume,
                  onChanged: (v) {
                    ref.read(playerStateProvider.notifier).setVolume(v);
                    _showControlsTemporarily();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showVolumeOverlay() {
    if (!mounted) return;
    _volumeOverlayTimer?.cancel();
    setState(() => _volumeOverlayVisible = true);
    _volumeOverlayTimer = Timer(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() => _volumeOverlayVisible = false);
    });
  }

    Widget _buildSpeedSliderPanel(
      ColorScheme colorScheme,
      double playbackSpeed,
    ) {
      if (!_showSpeedSlider) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Reset to 1x',
              style: _controlButtonStyle(colorScheme),
              iconSize: 20,
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                widget.controller.setPlaybackSpeed(1.0);
                _showControlsTemporarily();
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                  activeTrackColor: colorScheme.primary,
                  inactiveTrackColor: colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.25,
                  ),
                  thumbColor: colorScheme.primary,
                ),
                child: Slider(
                  value: playbackSpeed.clamp(0.25, 3.0),
                  min: 0.25,
                  max: 3.0,
                  divisions: 11,
                  onChanged: (v) {
                    widget.controller.setPlaybackSpeed(v);
                    _showControlsTemporarily();
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Close speed slider',
              style: _controlButtonStyle(colorScheme),
              iconSize: 20,
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                setState(() => _showSpeedSlider = false);
                _showControlsTemporarily();
              },
            ),
          ],
        ),
      );
    }

    Widget _buildVolumeOverlay(ColorScheme colorScheme) {
    final desktopSettings = ref.watch(desktopSettingsProvider);
    final volume = desktopSettings.volume;
    final isMuted = desktopSettings.isMuted;

    IconData iconData = Icons.volume_up_rounded;
    if (isMuted || volume == 0) {
      iconData = Icons.volume_off_rounded;
    } else if (volume < 0.5) {
      iconData = Icons.volume_down_rounded;
    }

    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: _volumeOverlayVisible ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(150),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(iconData, color: Colors.white, size: 48),
                const SizedBox(height: 8),
                Text(
                  isMuted ? 'Muted' : '${(volume * 100).round()}%',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final playerState = ref.watch(playerStateProvider);

    if (playerState.isInPipMode) {
      return const SizedBox.shrink();
    }

    final value = widget.controller.value;
    final duration = value.duration;
    final durationMs = math.max(1, duration.inMilliseconds);
    final playbackSpeed = value.playbackSpeed;
    final isFullScreen = playerState.isFullScreen;
    final queueState = ref.watch(playbackQueueProvider);
    final nextScene =
        (queueState.currentIndex >= 0 &&
            queueState.currentIndex < queueState.sequence.length - 1)
        ? queueState.sequence[queueState.currentIndex + 1]
        : null;

    final currentMs = _isScrubbing
        ? _scrubMs
        : value.position.inMilliseconds.toDouble();
    final sliderValue = currentMs.clamp(0, durationMs.toDouble()).toDouble();

    final isDesktop = ref.watch(desktopCapabilitiesProvider);
    final keybinds = ref.watch(keybindsProvider);

    Map<ShortcutActivator, VoidCallback> bindings = {};
    for (var entry in keybinds.binds.entries) {
      final action = entry.key;
      final bind = entry.value;

      VoidCallback? callback;
      switch (action) {
        case KeybindAction.playPause:
          callback = _togglePlay;
          break;
        case KeybindAction.seekForward:
          callback = () => _seekRelativeSeconds(5);
          break;
        case KeybindAction.seekBackward:
          callback = () => _seekRelativeSeconds(-5);
          break;
        case KeybindAction.seekForwardLarge:
          callback = () => _seekRelativeSeconds(10);
          break;
        case KeybindAction.seekBackwardLarge:
          callback = () => _seekRelativeSeconds(-10);
          break;
        case KeybindAction.volumeUp:
          callback = () {
            final currentVol = ref.read(desktopSettingsProvider).volume;
            ref.read(playerStateProvider.notifier).setVolume(currentVol + 0.05);
          };
          break;
        case KeybindAction.volumeDown:
          callback = () {
            final currentVol = ref.read(desktopSettingsProvider).volume;
            ref.read(playerStateProvider.notifier).setVolume(currentVol - 0.05);
          };
          break;
        case KeybindAction.toggleMute:
          callback = () => ref.read(playerStateProvider.notifier).toggleMute();
          break;
        case KeybindAction.toggleFullscreen:
          callback = () => widget.onFullScreenToggle?.call();
          break;
        case KeybindAction.togglePip:
          callback = () {
            if (widget.enableNativePip && !kIsWeb && Platform.isAndroid) {
              PipMode.enterIfAvailable(
                aspectRatio: widget.controller.value.aspectRatio,
              );
            }
          };
          break;
        case KeybindAction.nextScene:
          callback = _playNext;
          break;
        case KeybindAction.previousScene:
          callback = _playPrevious;
          break;
        case KeybindAction.speedUp:
          callback = () {
            final currentSpeed = widget.controller.value.playbackSpeed;
            widget.controller.setPlaybackSpeed(currentSpeed + 0.25);
          };
          break;
        case KeybindAction.speedDown:
          callback = () {
            final currentSpeed = widget.controller.value.playbackSpeed;
            widget.controller.setPlaybackSpeed(currentSpeed - 0.25);
          };
          break;
        case KeybindAction.resetSpeed:
          callback = () => widget.controller.setPlaybackSpeed(1.0);
          break;
        case KeybindAction.closePlayer:
          callback = () => ref.read(playerStateProvider.notifier).stop();
          break;
        case KeybindAction.back:
          callback = () {
            ref.read(playerStateProvider.notifier).stop();
            if (context.canPop()) {
              context.pop();
            }
          };
          break;
        default:
          break;
      }

      if (callback != null) {
        bindings[bind.toActivator()] = callback;
      }
    }

    return PopScope(
      canPop: !_isScrubbing,
      child: CallbackShortcuts(
        bindings: bindings,
        child: Focus(
          autofocus: true,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Layer 0: Background Gesture Area (Handles toggle and seek)
                  Positioned.fill(
                    child: MouseRegion(
                      onHover: (_) => _showControlsTemporarily(),
                      onEnter: (_) => _showControlsTemporarily(),
                      child: Listener(
                        onPointerSignal: (pointerSignal) {
                          if (pointerSignal is PointerScrollEvent) {
                            if (pointerSignal.scrollDelta.dy != 0) {
                              // Vertical scroll -> Volume
                              final currentVol = ref
                                  .read(desktopSettingsProvider)
                                  .volume;
                              if (pointerSignal.scrollDelta.dy < 0) {
                                ref
                                    .read(playerStateProvider.notifier)
                                    .setVolume(currentVol + 0.05);
                              } else {
                                ref
                                    .read(playerStateProvider.notifier)
                                    .setVolume(currentVol - 0.05);
                              }
                            } else if (pointerSignal.scrollDelta.dx != 0) {
                              // Horizontal scroll -> Seek
                              if (pointerSignal.scrollDelta.dx > 0) {
                                _seekRelativeSeconds(5);
                              } else {
                                _seekRelativeSeconds(-5);
                              }
                            }
                          }
                        },
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _toggleControls,
                          onDoubleTapDown: widget.useDoubleTapSeek
                              ? (details) {
                                  if (details.localPosition.dx <
                                      constraints.maxWidth / 2) {
                                    _seekRelativeSeconds(-_gestureSeekSeconds);
                                  } else {
                                    _seekRelativeSeconds(_gestureSeekSeconds);
                                  }
                                }
                              : null,
                          onDoubleTap: isDesktop
                              ? () {
                                  widget.onFullScreenToggle?.call();
                                }
                              : null,
                          onHorizontalDragStart: !widget.useDoubleTapSeek
                              ? (_) => _beginDragSeek()
                              : null,
                          onHorizontalDragUpdate: !widget.useDoubleTapSeek
                              ? (details) => _updateDragSeek(
                                  details,
                                  constraints.maxWidth,
                                )
                              : null,
                          onHorizontalDragEnd: !widget.useDoubleTapSeek
                              ? (_) => _endDragSeek()
                              : null,
                          onHorizontalDragCancel: !widget.useDoubleTapSeek
                              ? () => _endDragSeek()
                              : null,
                          child: const ColoredBox(color: Colors.transparent),
                        ),
                      ),
                    ),
                  ),

                  Positioned.fill(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_dragSeekTarget != null &&
                              (widget.scene.paths.vtt?.isNotEmpty ??
                                  false)) ...[
                            ScrubbingPreview(
                              vttUrl: widget.scene.paths.vtt!,
                              timeInSeconds:
                                  _dragSeekTarget!.inMilliseconds / 1000,
                              headers: ref.read(mediaPlaybackHeadersProvider),
                            ),
                            const SizedBox(height: 16),
                          ],
                          _buildSeekFeedbackOverlay(colorScheme),
                        ],
                      ),
                    ),
                  ),

                  Positioned.fill(child: _buildVolumeOverlay(colorScheme)),

                  // Layer: Scrubbing Preview (Floating above the slider)
                  if (_isScrubbing &&
                      (widget.scene.paths.vtt?.isNotEmpty ?? false))
                    Positioned(
                      bottom: 84, // Positioned above the slider
                      left: 0,
                      right: 0,
                      height: 100, // Enough height for 160x90 preview
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final double ratio = _scrubMs / durationMs;
                          const double previewWidth = 160;

                          // Track is inset slightly from edges
                          final double trackWidth = constraints.maxWidth - 32;
                          final double thumbX = 16 + (ratio * trackWidth);

                          double leftOffset = thumbX - (previewWidth / 2);

                          // Edge protection
                          if (leftOffset < 8) {
                            leftOffset = 8;
                          } else if (leftOffset + previewWidth >
                              constraints.maxWidth - 8) {
                            leftOffset =
                                constraints.maxWidth - previewWidth - 8;
                          }

                          return Stack(
                            children: [
                              Positioned(
                                left: leftOffset,
                                top: 0,
                                child: ScrubbingPreview(
                                  vttUrl: widget.scene.paths.vtt!,
                                  timeInSeconds: _scrubMs / 1000,
                                  headers: ref.read(
                                    mediaPlaybackHeadersProvider,
                                  ),
                                  width: 160,
                                  height: 90,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                  // Layer 1: UI Overlays
                  // Debug Info (Follows controls visibility or always visible if you prefer)
                  if (playerState.showVideoDebugInfo)
                    Positioned(
                      top: isFullScreen ? 60 : 8,
                      left: 8,
                      child: IgnorePointer(
                        child: AnimatedOpacity(
                          opacity: _controlsVisible ? 1 : 0,
                          duration: const Duration(milliseconds: 180),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(130),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSmall,
                              ),
                            ),
                            child: Text(
                              'mime: ${playerState.streamMimeType ?? 'unknown'}'
                              '${playerState.streamLabel == null || playerState.streamLabel!.isEmpty ? '' : '  label: ${playerState.streamLabel}'}'
                              '${playerState.streamSource == null || playerState.streamSource!.isEmpty ? '' : '  src: ${playerState.streamSource}'}'
                              '${playerState.prewarmAttempted != true ? '' : '  prewarm: ${playerState.prewarmSucceeded == true ? 'ok' : 'fail'}${playerState.prewarmLatencyMs == null ? '' : '/${playerState.prewarmLatencyMs}ms'}'}'
                              '${playerState.startupLatencyMs == null ? '' : '  start: ${playerState.startupLatencyMs}ms'}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (isFullScreen && widget.onFullScreenToggle != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      right: 8,
                      child: SafeArea(
                        child: AnimatedOpacity(
                          opacity: _controlsVisible ? 1 : 0,
                          duration: const Duration(milliseconds: 180),
                          child: Row(
                            children: [
                              IconButton(
                                tooltip: 'Exit Fullscreen',
                                style: _controlButtonStyle(colorScheme),
                                icon: const Icon(Icons.arrow_back_rounded),
                                onPressed: () {
                                  widget.onFullScreenToggle?.call();
                                  _showControlsTemporarily();
                                },
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.scene.displayTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 4,
                                        color: Colors.black54,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Bottom Control Bar
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: IgnorePointer(
                      ignoring: !_controlsVisible,
                      child: AnimatedSlide(
                        offset: _controlsVisible
                            ? Offset.zero
                            : const Offset(0, 0.08),
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        child: AnimatedOpacity(
                          opacity: _controlsVisible ? 1 : 0,
                          duration: const Duration(milliseconds: 180),
                          child: GestureDetector(
                            onTap: () {},
                            behavior: HitTestBehavior.opaque,
                            child: RepaintBoundary(
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(6, 0, 6, 6),
                                padding: const EdgeInsets.fromLTRB(
                                  10,
                                  8,
                                  10,
                                  6,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface.withValues(
                                    alpha: 0.62,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMedium,
                                  ),
                                  border: Border.all(
                                    color: colorScheme.outlineVariant
                                        .withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildSpeedSliderPanel(
                                      colorScheme,
                                      playbackSpeed,
                                    ),
                                    VideoProgressBar(
                                      durationMs: durationMs,
                                      sliderValue: sliderValue,
                                      onChangeStart: (v) {
                                        _wasPlayingBeforeScrub =
                                            value.isPlaying;
                                        _cancelAutoHide();
                                        setState(() {
                                          _isScrubbing = true;
                                          _scrubMs = v;
                                          _controlsVisible = true;
                                        });
                                      },
                                      onChanged: (v) {
                                        setState(() => _scrubMs = v);
                                      },
                                      onChangeEnd: (v) {
                                        final target = Duration(
                                          milliseconds: v.round(),
                                        );
                                        unawaited(() async {
                                          await _seekToKeepingPlayback(
                                            target,
                                            keepPlayingAfterSeek:
                                                _wasPlayingBeforeScrub,
                                          );
                                        }());
                                        setState(() {
                                          _isScrubbing = false;
                                          _scrubMs = 0;
                                        });
                                        _wasPlayingBeforeScrub = false;
                                        _scheduleAutoHide();
                                      },
                                    ),
                                    const SizedBox(height: 2),
                                    VideoPlaybackControls(
                                      controller: widget.controller,
                                      scene: widget.scene,
                                      isPlaying: value.isPlaying,
                                      playbackSpeed: playbackSpeed,
                                      nextScene: nextScene,
                                      isFullScreen: isFullScreen,
                                      onPlayPause: () {
                                        if (value.isPlaying) {
                                          widget.controller.pause();
                                        } else {
                                          widget.controller.play();
                                        }
                                      },
                                      onSkipNext: () {
                                        ref
                                            .read(playerStateProvider.notifier)
                                            .playNext();
                                      },
                                      onSubtitleSelected: (val) async {
                                        if (val == null || val == 'none') {
                                          await ref
                                              .read(
                                                playerStateProvider.notifier,
                                              )
                                              .setSubtitle('none');
                                        } else {
                                          final parts = val.split(':');
                                          final lang = parts[0];
                                          final type = parts.length > 1
                                              ? parts[1]
                                              : '';
                                          await ref
                                              .read(
                                                playerStateProvider.notifier,
                                              )
                                              .setSubtitle(
                                                lang,
                                                captionType: type,
                                              );
                                        }
                                      },
                                      onSpeedSelected: (speed) async {
                                        await widget.controller
                                            .setPlaybackSpeed(speed);
                                      },
                                      onFullScreenToggle:
                                          widget.onFullScreenToggle,
                                      enableNativePip: widget.enableNativePip,
                                      onInteract: _showControlsTemporarily,
                                      desktopVolumeControl:
                                          ref.watch(desktopCapabilitiesProvider)
                                          ? _buildDesktopVolumeControl(
                                              context,
                                              colorScheme,
                                            )
                                          : null,
                                      selectedSubtitleLanguage:
                                          playerState.selectedSubtitleLanguage,
                                      selectedSubtitleType:
                                          playerState.selectedSubtitleType,
                                      formattedCurrentTime: _format(
                                        Duration(
                                          milliseconds: sliderValue.round(),
                                        ),
                                      ),
                                      formattedDuration: _format(duration),
                                      onSpeedTap: () {
                                        setState(() => _showSpeedSlider = !_showSpeedSlider);
                                        _showControlsTemporarily();
                                      },
                                      isSpeedSliderVisible: _showSpeedSlider,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
