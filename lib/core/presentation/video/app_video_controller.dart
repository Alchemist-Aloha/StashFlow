import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart' as vp;

class AppDurationRange {
  final Duration start;
  final Duration end;

  const AppDurationRange({required this.start, required this.end});
}

class AppVideoValue {
  final bool isInitialized;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double playbackSpeed;
  final double aspectRatio;
  final Size size;
  final String captionText;
  final List<AppDurationRange> buffered;

  const AppVideoValue({
    required this.isInitialized,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.playbackSpeed,
    required this.aspectRatio,
    required this.size,
    required this.captionText,
    required this.buffered,
  });
}

abstract class AppVideoController implements ValueListenable<AppVideoValue> {
  String get dataSource;

  Future<void> initialize();
  Future<void> play();
  Future<void> pause();
  Future<void> seekTo(Duration position);
  Future<void> setLooping(bool value);
  Future<void> setPlaybackSpeed(double speed);
  Future<void> setVolume(double volume);
  Future<void> dispose();
}

class VideoPlayerControllerAdapter extends ValueNotifier<AppVideoValue>
    implements AppVideoController {
  final vp.VideoPlayerController _controller;

  VideoPlayerControllerAdapter._(this._controller)
      : super(_mapValue(_controller.value)) {
    _controller.addListener(_syncValue);
  }

  factory VideoPlayerControllerAdapter.networkUrl(
    Uri url, {
    Map<String, String> httpHeaders = const <String, String>{},
    Future<vp.ClosedCaptionFile>? closedCaptionFile,
    bool allowBackgroundPlayback = false,
    bool mixWithOthers = true,
  }) {
    final controller = vp.VideoPlayerController.networkUrl(
      url,
      httpHeaders: httpHeaders,
      closedCaptionFile: closedCaptionFile,
      videoPlayerOptions: vp.VideoPlayerOptions(
        allowBackgroundPlayback: allowBackgroundPlayback,
        mixWithOthers: mixWithOthers,
      ),
    );

    return VideoPlayerControllerAdapter._(controller);
  }

  static AppVideoValue _mapValue(vp.VideoPlayerValue value) {
    return AppVideoValue(
      isInitialized: value.isInitialized,
      isPlaying: value.isPlaying,
      position: value.position,
      duration: value.duration,
      playbackSpeed: value.playbackSpeed,
      aspectRatio: value.aspectRatio,
      size: value.size,
      captionText: value.caption.text,
      buffered: value.buffered
          .map((range) => AppDurationRange(
                start: range.start,
                end: range.end,
              ))
          .toList(growable: false),
    );
  }

  void _syncValue() {
    value = _mapValue(_controller.value);
  }

  vp.VideoPlayerController get rawController => _controller;

  @override
  String get dataSource => _controller.dataSource;

  @override
  Future<void> initialize() => _controller.initialize();

  @override
  Future<void> play() => _controller.play();

  @override
  Future<void> pause() => _controller.pause();

  @override
  Future<void> seekTo(Duration position) => _controller.seekTo(position);

  @override
  Future<void> setLooping(bool value) => _controller.setLooping(value);

  @override
  Future<void> setPlaybackSpeed(double speed) =>
      _controller.setPlaybackSpeed(speed);

  @override
  Future<void> setVolume(double volume) => _controller.setVolume(volume);

  @override
  Future<void> dispose() async {
    _controller.removeListener(_syncValue);
    await _controller.dispose();
    super.dispose();
  }
}
