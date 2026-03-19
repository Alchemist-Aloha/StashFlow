import 'dart:async';
import 'dart:math' as math;

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ScrubChewieControls extends StatefulWidget {
  const ScrubChewieControls({required this.useDoubleTapSeek, super.key});

  final bool useDoubleTapSeek;

  @override
  State<ScrubChewieControls> createState() => _ScrubChewieControlsState();
}

class _ScrubChewieControlsState extends State<ScrubChewieControls> {
  ChewieController? _chewieController;
  VideoPlayerController? _boundVideoController;
  static const _playbackSpeeds = <double>[0.75, 1.0, 1.25, 1.5, 2.0];
  static const _controlsAutoHideDelay = Duration(seconds: 3);
  static const _gestureSeekSeconds = 10;
  static const _controlsTouchSafeHeight = 122.0;
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextController = ChewieController.of(context);
    if (identical(nextController, _chewieController)) return;

    _boundVideoController?.removeListener(_onVideoTick);
    _chewieController = nextController;
    _boundVideoController = nextController.videoPlayerController;
    _boundVideoController?.addListener(_onVideoTick);

    final isPlaying = _boundVideoController?.value.isPlaying ?? false;
    _wasPlaying = isPlaying;
    if (isPlaying) {
      _scheduleAutoHide();
    } else {
      _cancelAutoHide();
      _controlsVisible = true;
    }
  }

  @override
  void dispose() {
    _cancelAutoHide();
    _boundVideoController?.removeListener(_onVideoTick);
    super.dispose();
  }

  void _onVideoTick() {
    if (!mounted) return;

    final isPlaying = _boundVideoController?.value.isPlaying ?? false;
    if (isPlaying != _wasPlaying) {
      _wasPlaying = isPlaying;
      if (isPlaying) {
        _scheduleAutoHide();
      } else {
        _cancelAutoHide();
        _controlsVisible = true;
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
    final isPlaying = _boundVideoController?.value.isPlaying ?? false;
    if (!isPlaying || _isScrubbing) return;

    _hideControlsTimer = Timer(_controlsAutoHideDelay, () {
      if (!mounted) return;
      final stillPlaying = _boundVideoController?.value.isPlaying ?? false;
      if (!stillPlaying || _isScrubbing || !_controlsVisible) return;
      setState(() => _controlsVisible = false);
    });
  }

  void _showControlsTemporarily() {
    if (!_controlsVisible) {
      setState(() => _controlsVisible = true);
    }
    _scheduleAutoHide();
  }

  void _seekRelativeSeconds(VideoPlayerController controller, int seconds) {
    if (!controller.value.isInitialized) return;
    final current = controller.value.position;
    final duration = controller.value.duration;
    var target = current + Duration(seconds: seconds);
    if (target < Duration.zero) target = Duration.zero;
    if (target > duration) target = duration;
    controller.seekTo(target);
  }

  void _beginDragSeek(VideoPlayerController controller) {
    if (!controller.value.isInitialized) return;
    _dragSeekStartPosition = controller.value.position;
    _dragSeekAccumulatedDx = 0;
  }

  void _updateDragSeek(
    VideoPlayerController controller,
    DragUpdateDetails details,
    double dragAreaWidth,
  ) {
    final startPosition = _dragSeekStartPosition;
    if (!controller.value.isInitialized || startPosition == null) return;
    if (dragAreaWidth <= 0) return;

    final duration = controller.value.duration;
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

    controller.seekTo(Duration(milliseconds: targetMs.round()));
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
    final chewieController = _chewieController ?? ChewieController.of(context);
    if (!identical(chewieController, _chewieController)) {
      _boundVideoController?.removeListener(_onVideoTick);
      _chewieController = chewieController;
      _boundVideoController = chewieController.videoPlayerController;
      _boundVideoController?.addListener(_onVideoTick);
    }

    final videoController = chewieController.videoPlayerController;
    final value = videoController.value;
    final duration = value.duration;
    final durationMs = math.max(1, duration.inMilliseconds);
    final playbackSpeed = value.playbackSpeed;

    final currentMs = _isScrubbing
        ? _scrubMs
        : value.position.inMilliseconds.toDouble();
    final sliderValue = currentMs.clamp(0, durationMs.toDouble()).toDouble();

    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            children: [
              Expanded(
                child: widget.useDoubleTapSeek
                    ? Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: _showControlsTemporarily,
                              onDoubleTap: () {
                                _seekRelativeSeconds(
                                  videoController,
                                  -_gestureSeekSeconds,
                                );
                                _showControlsTemporarily();
                              },
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: _showControlsTemporarily,
                              onDoubleTap: () {
                                _seekRelativeSeconds(
                                  videoController,
                                  _gestureSeekSeconds,
                                );
                                _showControlsTemporarily();
                              },
                            ),
                          ),
                        ],
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _showControlsTemporarily,
                            onHorizontalDragStart: (_) {
                              _beginDragSeek(videoController);
                            },
                            onHorizontalDragUpdate: (details) {
                              _updateDragSeek(
                                videoController,
                                details,
                                constraints.maxWidth,
                              );
                              _showControlsTemporarily();
                            },
                            onHorizontalDragEnd: (_) {
                              _endDragSeek();
                              _showControlsTemporarily();
                            },
                            onHorizontalDragCancel: _endDragSeek,
                          );
                        },
                      ),
              ),
              const SizedBox(height: _controlsTouchSafeHeight),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedOpacity(
            opacity: _controlsVisible ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            child: IgnorePointer(
              ignoring: !_controlsVisible,
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
                          videoController.seekTo(target);
                          setState(() {
                            _isScrubbing = false;
                            _scrubMs = 0;
                          });
                          _showControlsTemporarily();
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
                                videoController.pause();
                              } else {
                                videoController.play();
                              }
                              _showControlsTemporarily();
                            },
                          ),
                        ),
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
                            await videoController.setPlaybackSpeed(speed);
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
                        IconButton(
                          icon: Icon(
                            chewieController.isFullScreen
                                ? Icons.fullscreen_exit_rounded
                                : Icons.fullscreen_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (chewieController.isFullScreen) {
                              chewieController.exitFullScreen();
                            } else {
                              chewieController.enterFullScreen();
                            }
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
      ],
    );
  }
}
