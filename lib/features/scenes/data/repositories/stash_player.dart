import 'dart:async';

import 'package:media_kit/media_kit.dart';

import 'stream_resolver.dart';

/// [Media.extras] key carrying the scene's full duration in milliseconds.
const stashDurationExtra = 'stashDurationMs';

/// Whether [url] is a Stash live transcode (`stream.mp4` / `stream.webm`).
///
/// These are ffmpeg pipes: no byte ranges, no known duration, and timestamps
/// restart at 0 even when Stash's `start=` parameter skips ahead.
bool isLiveTranscode(String url) =>
    const {'mp4', 'webm'}.contains(streamSourceKind(url));

/// A [Player] that presents Stash live transcodes on the scene's timeline.
///
/// While a live transcode is open, seeking reopens it with `start=`, and
/// position, buffer and duration are reported as absolute scene time, so
/// controls, resume saving, markers and media sessions need no special cases.
/// Other media pass straight through to [Player].
// shortcut: mpv playlist looping (feed loop mode) replays a live transcode
// from its last start offset, not 0:00; reopen at zero on completion if
// looping live sources matters.
class StashPlayer extends Player {
  StashPlayer({super.configuration});

  /// Media as opened by the caller, without `start=`; null when not live.
  Media? _live;
  Duration _offset = Duration.zero;
  Duration _liveDuration = Duration.zero;

  /// Scene time at which the current live transcode began.
  Duration get liveOffset => _offset;

  Duration _shift(Duration d) => _live == null ? d : d + _offset;

  @override
  PlayerState get state {
    final s = super.state;
    if (_live == null) return s;
    return s.copyWith(
      position: s.position + _offset,
      buffer: s.buffer + _offset,
      duration: _liveDuration > Duration.zero ? _liveDuration : s.duration,
    );
  }

  @override
  late final PlayerStream stream = _mapStream(super.stream);

  PlayerStream _mapStream(PlayerStream s) => PlayerStream(
    s.playlist,
    s.playing,
    s.completed,
    s.position.map(_shift),
    s.duration.map(
      (d) => _live != null && _liveDuration > Duration.zero ? _liveDuration : d,
    ),
    s.volume,
    s.rate,
    s.pitch,
    s.buffering,
    s.bufferingPercentage,
    s.buffer.map(_shift),
    s.playlistMode,
    s.audioParams,
    s.videoParams,
    s.audioBitrate,
    s.videoBitrate,
    s.audioDevice,
    s.audioDevices,
    s.track,
    s.tracks,
    s.width,
    s.height,
    s.subtitle,
    s.log,
    s.error,
  );

  @override
  Future<void> open(Playable playable, {bool play = true}) async {
    if (playable is Media && isLiveTranscode(playable.uri)) {
      final ms = playable.extras?[stashDurationExtra];
      // Keep the known length when switching from a seekable source.
      final known = _live == null ? super.state.duration : _liveDuration;
      _liveDuration = ms is int ? Duration(milliseconds: ms) : known;
      _live = playable;
      return _openLive(playable.start ?? Duration.zero, play: play);
    }
    _live = null;
    _offset = Duration.zero;
    await _setSubDelay(Duration.zero);
    return super.open(playable, play: play);
  }

  @override
  Future<void> seek(Duration duration) async {
    final live = _live;
    if (live == null) return super.seek(duration);
    final subtitle = super.state.track.subtitle;
    await _openLive(duration, play: super.state.playing);
    // Reopening drops external subtitle tracks; restore the active one.
    if (subtitle.uri || subtitle.data) await setSubtitleTrack(subtitle);
  }

  Future<void> _openLive(Duration start, {required bool play}) async {
    final live = _live!;
    final clamped = start < Duration.zero ? Duration.zero : start;
    _offset = clamped;
    final uri = Uri.parse(live.uri);
    final url = uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        'start': (clamped.inMilliseconds / 1000).toStringAsFixed(3),
      },
    );
    await super.open(
      Media(url.toString(), extras: live.extras, httpHeaders: live.httpHeaders),
      play: play,
    );
    // Subtitles use scene time; the transcode's clock starts at [start].
    await _setSubDelay(-clamped);
  }

  Future<void> _setSubDelay(Duration delay) async {
    if (platform case final NativePlayer native) {
      await native.setProperty(
        'sub-delay',
        (delay.inMilliseconds / 1000).toStringAsFixed(3),
      );
    }
  }
}
