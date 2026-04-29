import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

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
  Future<void> setSubtitleUrl(String? url);
  Future<void> dispose();
}

class MediaKitVideoControllerAdapter extends ValueNotifier<AppVideoValue>
    implements AppVideoController {
  final Player _player;
  final VideoController _videoController;
  final String _dataSource;
  final Map<String, String> _httpHeaders;
  String? _subtitleUrl;

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  bool _isInitialized = false;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Duration _buffered = Duration.zero;
  double _playbackSpeed = 1.0;
  double _aspectRatio = 16 / 9;
  Size _size = const Size(1, 1);
  String _captionText = '';

  MediaKitVideoControllerAdapter._(
    this._player,
    this._videoController,
    this._dataSource,
    this._httpHeaders,
    this._subtitleUrl,
  ) : super(
          const AppVideoValue(
            isInitialized: false,
            isPlaying: false,
            position: Duration.zero,
            duration: Duration.zero,
            playbackSpeed: 1.0,
            aspectRatio: 16 / 9,
            size: Size(1, 1),
            captionText: '',
            buffered: <AppDurationRange>[],
          ),
        ) {
    _bindStreams();
  }

  factory MediaKitVideoControllerAdapter.networkUrl(
    Uri url, {
    Map<String, String> httpHeaders = const <String, String>{},
    String? subtitleUrl,
  }) {
    final player = Player();
    final videoController = VideoController(player);
    return MediaKitVideoControllerAdapter._(
      player,
      videoController,
      url.toString(),
      httpHeaders,
      subtitleUrl,
    );
  }

  VideoController get videoController => _videoController;

  void _bindStreams() {
    _subscriptions.add(
      _player.stream.playing.listen((playing) {
        _isPlaying = playing;
        _emitValue();
      }),
    );

    _subscriptions.add(
      _player.stream.position.listen((position) {
        _position = position;
        _emitValue();
      }),
    );

    _subscriptions.add(
      _player.stream.duration.listen((duration) {
        _duration = duration;
        _emitValue();
      }),
    );

    _subscriptions.add(
      _player.stream.buffer.listen((buffered) {
        _buffered = buffered;
        _emitValue();
      }),
    );

    _subscriptions.add(
      _player.stream.rate.listen((rate) {
        _playbackSpeed = rate;
        _emitValue();
      }),
    );

    _subscriptions.add(
      _player.stream.videoParams.listen((params) {
        final width = (params.w ?? 0).toDouble();
        final height = (params.h ?? 0).toDouble();
        if (width > 0 && height > 0) {
          _size = Size(width, height);
          _aspectRatio = width / height;
        }
        _emitValue();
      }),
    );

    _subscriptions.add(
      _player.stream.subtitle.listen((subtitle) {
        _captionText = subtitle.join('\n');
        _emitValue();
      }),
    );
  }

  void _emitValue() {
    value = AppVideoValue(
      isInitialized: _isInitialized,
      isPlaying: _isPlaying,
      position: _position,
      duration: _duration,
      playbackSpeed: _playbackSpeed,
      aspectRatio: _aspectRatio,
      size: _size,
      captionText: _captionText,
      buffered: _buffered > Duration.zero
          ? <AppDurationRange>[
              AppDurationRange(start: Duration.zero, end: _buffered),
            ]
          : const <AppDurationRange>[],
    );
  }

  @override
  String get dataSource => _dataSource;

  @override
  Future<void> initialize() async {
    await _player.open(
      Media(_dataSource, httpHeaders: _httpHeaders),
      play: false,
    );
    _isInitialized = true;
    await setSubtitleUrl(_subtitleUrl);
    _emitValue();
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seekTo(Duration position) => _player.seek(position);

  @override
  Future<void> setLooping(bool value) =>
      _player.setPlaylistMode(value ? PlaylistMode.loop : PlaylistMode.none);

  @override
  Future<void> setPlaybackSpeed(double speed) => _player.setRate(speed);

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume * 100.0);

  @override
  Future<void> setSubtitleUrl(String? url) async {
    _subtitleUrl = url;
    if (!_isInitialized) return;
    if (url == null || url.isEmpty) {
      await _player.setSubtitleTrack(SubtitleTrack.no());
      return;
    }
    await _player.setSubtitleTrack(SubtitleTrack.uri(url));
  }

  @override
  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    await _player.dispose();
    super.dispose();
  }
}
