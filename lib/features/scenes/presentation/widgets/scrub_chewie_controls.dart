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
  late ChewieController _chewieController;
  VideoPlayerController get _videoController =>
      _chewieController.videoPlayerController;

  bool _isScrubbing = false;
  double _scrubMs = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextController = ChewieController.of(context);
    if (!identical(nextController, _chewieController)) {
      _chewieController = nextController;
      _videoController.removeListener(_onVideoTick);
      _videoController.addListener(_onVideoTick);
    }
  }

  @override
  void dispose() {
    _videoController.removeListener(_onVideoTick);
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

  @override
  Widget build(BuildContext context) {
    final value = _videoController.value;
    final duration = value.duration;
    final durationMs = math.max(1, duration.inMilliseconds);

    final currentMs = _isScrubbing
        ? _scrubMs
        : value.position.inMilliseconds.toDouble();
    final sliderValue =
      currentMs.clamp(0, durationMs.toDouble()).toDouble();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.black.withValues(alpha: 0.45),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
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
                  _videoController.seekTo(target);
                  setState(() {
                    _isScrubbing = false;
                    _scrubMs = 0;
                  });
                },
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (value.isPlaying) {
                      _videoController.pause();
                    } else {
                      _videoController.play();
                    }
                    setState(() {});
                  },
                ),
                Text(
                  '${_format(Duration(milliseconds: sliderValue.round()))} / ${_format(duration)}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    _chewieController.isFullScreen
                        ? Icons.fullscreen_exit
                        : Icons.fullscreen,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (_chewieController.isFullScreen) {
                      _chewieController.exitFullScreen();
                    } else {
                      _chewieController.enterFullScreen();
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
