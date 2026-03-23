import 'dart:async';
import 'dart:math' as math;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/utils/pip_mode.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/utils/app_log_store.dart';
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_title_utils.dart';
import '../providers/video_player_provider.dart';
import '../providers/playback_queue_provider.dart';

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
  ConsumerState<NativeVideoControls> createState() => _NativeVideoControlsState();
}

class _NativeVideoControlsState extends ConsumerState<NativeVideoControls>
    with WidgetsBindingObserver {
  static const _playbackSpeeds = <double>[0.75, 1.0, 1.25, 1.5, 2.0];
  static const _controlsAutoHideDelay = Duration(milliseconds: 1000);
  static const _gestureSeekSeconds = 10;
  static const _dragSeekSensitivity = 0.30;
  static const _dragSeekCurveExponent = 1.6;

  bool _isScrubbing = false;
  double _scrubMs = 0;
  bool _controlsVisible = true;
  bool _wasPlaying = false;
  Timer? _hideControlsTimer;
  Duration? _dragSeekStartPosition;
  double _dragSeekAccumulatedDx = 0;

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
    widget.controller.removeListener(_onVideoTick);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.enableNativePip || !Platform.isAndroid) return;
    if (state != AppLifecycleState.paused) return;

    final controller = widget.controller;
    if (!controller.value.isPlaying) return;
    
    final isFullScreen = ref.read(playerStateProvider).isFullScreen;
    if (!isFullScreen) return;
    
    unawaited(PipMode.enterIfAvailable(aspectRatio: controller.value.aspectRatio));
  }

  void _onVideoTick() {
    if (!mounted) return;
    
    final isActive = ref.read(playerStateProvider).activeScene?.id == widget.scene.id;
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
    if (!_controlsVisible) {
      setState(() => _controlsVisible = true);
    }
    _scheduleAutoHide();
  }

  void _seekRelativeSeconds(int seconds) {
    if (!widget.controller.value.isInitialized) return;
    final current = widget.controller.value.position;
    final duration = widget.controller.value.duration;
    var target = current + Duration(seconds: seconds);
    if (target < Duration.zero) target = Duration.zero;
    if (target > duration) target = duration;
    widget.controller.seekTo(target);
  }

  void _beginDragSeek() {
    final isActive = ref.read(playerStateProvider).activeScene?.id == widget.scene.id;
    if (!isActive) return;

    if (!widget.controller.value.isInitialized) return;
    _dragSeekStartPosition = widget.controller.value.position;
    _dragSeekAccumulatedDx = 0;
    
    AppLogStore.instance.add(
      'NativeVideoControls beginDragSeek scene=${widget.scene.id}',
      source: 'NativeVideoControls',
    );
  }

  void _updateDragSeek(DragUpdateDetails details, double dragAreaWidth) {
    final isActive = ref.read(playerStateProvider).activeScene?.id == widget.scene.id;
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

    widget.controller.seekTo(Duration(milliseconds: targetMs.round()));
  }

  void _endDragSeek() {
    _dragSeekStartPosition = null;
    _dragSeekAccumulatedDx = 0;
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

  String _formatSpeed(double speed) {
    final whole = speed.roundToDouble() == speed;
    return whole
        ? '${speed.toStringAsFixed(0)}x'
        : '${speed.toStringAsFixed(2)}x';
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerStateProvider);

    if (playerState.isInPipMode) {
      return const SizedBox.shrink();
    }

    final value = widget.controller.value;
    final duration = value.duration;
    final durationMs = math.max(1, duration.inMilliseconds);
    final playbackSpeed = value.playbackSpeed;
    final isFullScreen = playerState.isFullScreen;
    final nextScene = ref.watch(playbackQueueProvider.notifier).getNextScene();

    final currentMs = _isScrubbing
        ? _scrubMs
        : value.position.inMilliseconds.toDouble();
    final sliderValue = currentMs.clamp(0, durationMs.toDouble()).toDouble();

    return PopScope(
      canPop: !_isScrubbing,
      child: LayoutBuilder(
        builder: (context, constraints) {
        return Stack(
          children: [
            // Layer 0: Background Gesture Area (Handles toggle and seek)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleControls,
                onDoubleTapDown: widget.useDoubleTapSeek
                    ? (details) {
                        if (details.localPosition.dx < constraints.maxWidth / 2) {
                          _seekRelativeSeconds(-_gestureSeekSeconds);
                        } else {
                          _seekRelativeSeconds(_gestureSeekSeconds);
                        }
                      }
                    : null,
                onDoubleTap: widget.useDoubleTapSeek ? () {} : null,
                onHorizontalDragStart: !widget.useDoubleTapSeek
                    ? (_) => _beginDragSeek()
                    : null,
                onHorizontalDragUpdate: !widget.useDoubleTapSeek
                    ? (details) => _updateDragSeek(details, constraints.maxWidth)
                    : null,
                onHorizontalDragEnd: !widget.useDoubleTapSeek
                    ? (_) => _endDragSeek()
                    : null,
                onHorizontalDragCancel:
                    !widget.useDoubleTapSeek ? _endDragSeek : null,
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),

            // Layer 1: UI Overlays
            // Debug Info (Follows controls visibility or always visible if you prefer)
            if (playerState.showVideoDebugInfo)
              Positioned(
                top: 8,
                left: 8,
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _controlsVisible ? 1 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(180),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: Text(
                        'mime: ${playerState.streamMimeType ?? 'unknown'}'
                        '${playerState.streamLabel == null || playerState.streamLabel!.isEmpty ? '' : '  label: ${playerState.streamLabel}'}'
                        '${playerState.streamSource == null || playerState.streamSource!.isEmpty ? '' : '  src: ${playerState.streamSource}'}'
                        '${playerState.prewarmAttempted != true ? '' : '  prewarm: ${playerState.prewarmSucceeded == true ? 'ok' : 'fail'}${playerState.prewarmLatencyMs == null ? '' : '/${playerState.prewarmLatencyMs}ms'}'}'
                        '${playerState.startupLatencyMs == null ? '' : '  start: ${playerState.startupLatencyMs}ms'}',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ),
                  ),
                ),
              ),

            // Bottom Control Bar
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedOpacity(
                opacity: _controlsVisible ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: IgnorePointer(
                  ignoring: !_controlsVisible,
                  child: GestureDetector(
                    onTap: () {}, // Block background toggle when interacting with controls
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x00000000),
                            Color(0x88000000),
                            Color(0xCC000000),
                          ],
                          stops: [0.0, 0.45, 1.0],
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(12, 18, 12, 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 7,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 14,
                              ),
                              activeTrackColor: const Color(0xFFECECEC),
                              inactiveTrackColor: const Color(0x55FFFFFF),
                              thumbColor: Colors.white,
                            ),
                            child: Slider(
                              min: 0,
                              max: durationMs.toDouble(),
                              value: sliderValue,
                              onChangeStart: (v) {
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
                                final target = Duration(milliseconds: v.round());
                                widget.controller.seekTo(target);
                                setState(() {
                                  _isScrubbing = false;
                                  _scrubMs = 0;
                                });
                                _scheduleAutoHide();
                              },
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Material(
                                color: const Color(0x30FFFFFF),
                                shape: const CircleBorder(),
                                child: IconButton(
                                  iconSize: 24,
                                  icon: Icon(
                                    value.isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    if (value.isPlaying) {
                                      widget.controller.pause();
                                    } else {
                                      widget.controller.play();
                                    }
                                    _showControlsTemporarily();
                                  },
                                ),
                              ),
                              if (nextScene != null) ...[
                                const SizedBox(width: 8),
                                Material(
                                  color: const Color(0x30FFFFFF),
                                  shape: const CircleBorder(),
                                  child: IconButton(
                                    iconSize: 24,
                                    icon: const Icon(
                                      Icons.skip_next_rounded,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      ref.read(playerStateProvider.notifier).playNext();
                                      _showControlsTemporarily();
                                    },
                                  ),
                                ),
                              ],
                              const SizedBox(width: 8),
                              Text(
                                '${_format(Duration(milliseconds: sliderValue.round()))} / ${_format(duration)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              PopupMenuButton<double>(
                                tooltip: 'Playback speed',
                                initialValue: playbackSpeed,
                                color: const Color(0xEE1C1C1C),
                                onSelected: (speed) async {
                                  await widget.controller.setPlaybackSpeed(speed);
                                  _showControlsTemporarily();
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
                                                    ? Colors.white
                                                    : Colors.white70,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                _formatSpeed(speed),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0x30FFFFFF),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _formatSpeed(playbackSpeed),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (widget.enableNativePip && Platform.isAndroid)
                                IconButton(
                                  tooltip: 'Picture-in-Picture',
                                  icon: const Icon(
                                    Icons.picture_in_picture_alt_outlined,
                                    color: Colors.white,
                                  ),
                                  onPressed: () async {
                                    if (!isFullScreen) {
                                      widget.onFullScreenToggle?.call();
                                      // Small delay to allow transition
                                      await Future.delayed(const Duration(milliseconds: 150));
                                    }
                                    await PipMode.enterIfAvailable(aspectRatio: widget.controller.value.aspectRatio);
                                    _showControlsTemporarily();
                                  },
                                ),
                              IconButton(
                                tooltip: 'Toggle Fullscreen',
                                icon: Icon(
                                  isFullScreen
                                      ? Icons.fullscreen_exit_rounded
                                      : Icons.fullscreen_rounded,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  widget.onFullScreenToggle?.call();
                                  _showControlsTemporarily();
                                },
                              ),
                            ],
                          ),
                        ],
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
    );
  }
}
