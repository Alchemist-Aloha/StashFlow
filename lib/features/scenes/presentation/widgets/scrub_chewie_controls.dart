import 'dart:math' as math;

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ScrubChewieControls extends StatefulWidget {
  const ScrubChewieControls({super.key});

  @override
  State<ScrubChewieControls> createState() => _ScrubChewieControlsState();
}

class _ScrubChewieControlsState extends State<ScrubChewieControls> {
  ChewieController? _chewieController;
  VideoPlayerController? _boundVideoController;
  static const _playbackSpeeds = <double>[0.75, 1.0, 1.25, 1.5, 2.0];

  bool _isScrubbing = false;
  double _scrubMs = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextController = ChewieController.of(context);
    if (identical(nextController, _chewieController)) return;

    _boundVideoController?.removeListener(_onVideoTick);
    _chewieController = nextController;
    _boundVideoController = nextController.videoPlayerController;
    _boundVideoController?.addListener(_onVideoTick);
  }

  @override
  void dispose() {
    _boundVideoController?.removeListener(_onVideoTick);
    super.dispose();
  }

  void _onVideoTick() {
    if (!mounted || _isScrubbing) return;
    setState(() {});
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
    return whole ? '${speed.toStringAsFixed(0)}x' : '${speed.toStringAsFixed(2)}x';
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

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x00000000), Color(0x88000000), Color(0xCC000000)],
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
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: const Color(0xFFECECEC),
                inactiveTrackColor: const Color(0x55FFFFFF),
                thumbColor: Colors.white,
              ),
              child: Slider(
                min: 0,
                max: durationMs.toDouble(),
                value: sliderValue,
                onChangeStart: (v) {
                  setState(() {
                    _isScrubbing = true;
                    _scrubMs = v;
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
                      value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (value.isPlaying) {
                        videoController.pause();
                      } else {
                        videoController.play();
                      }
                      setState(() {});
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
                    if (mounted) setState(() {});
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
                                  style: const TextStyle(color: Colors.white),
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
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
