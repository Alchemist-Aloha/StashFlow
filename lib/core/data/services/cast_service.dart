import 'dart:async';
import 'package:dart_cast/dart_cast.dart' as dc;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/app_log_store.dart';

void logCastProcess(String message, {String source = 'cast_service'}) {
  if (AppLogStore.instance.isEnabled) {
    AppLogStore.instance.add(message, source: source);
    return;
  }
  debugPrint(message);
}

class CastState {
  final List<dc.CastDevice> discoveredDevices;
  final dc.CastSession? activeSession;
  final bool isCasting;
  final Duration? localResumePosition;
  final bool localWasPlaying;
  final Duration remotePosition;
  final Duration remoteDuration;
  final bool remoteIsPlaying;

  /// Whether the remote transport is stopped/idle rather than paused.
  ///
  /// A stopped renderer has no current URI to resume, so playing again means
  /// re-pointing the media instead of sending `Play`.
  final bool remoteIsStopped;
  final int completedMediaCount;

  CastState({
    this.discoveredDevices = const [],
    this.activeSession,
    this.isCasting = false,
    this.localResumePosition,
    this.localWasPlaying = false,
    this.remotePosition = Duration.zero,
    this.remoteDuration = Duration.zero,
    this.remoteIsPlaying = false,
    this.remoteIsStopped = false,
    this.completedMediaCount = 0,
  });

  CastState copyWith({
    List<dc.CastDevice>? discoveredDevices,
    dc.CastSession? activeSession,
    bool? isCasting,
    Duration? localResumePosition,
    bool? localWasPlaying,
    Duration? remotePosition,
    Duration? remoteDuration,
    bool? remoteIsPlaying,
    bool? remoteIsStopped,
    int? completedMediaCount,
    bool clearActiveSession = false,
    bool clearLocalHandoff = false,
  }) {
    return CastState(
      discoveredDevices: discoveredDevices ?? this.discoveredDevices,
      activeSession: clearActiveSession
          ? null
          : (activeSession ?? this.activeSession),
      isCasting: isCasting ?? this.isCasting,
      localResumePosition: clearLocalHandoff
          ? null
          : (localResumePosition ?? this.localResumePosition),
      localWasPlaying: clearLocalHandoff
          ? false
          : (localWasPlaying ?? this.localWasPlaying),
      remotePosition: remotePosition ?? this.remotePosition,
      remoteDuration: remoteDuration ?? this.remoteDuration,
      remoteIsPlaying: remoteIsPlaying ?? this.remoteIsPlaying,
      remoteIsStopped: remoteIsStopped ?? this.remoteIsStopped,
      completedMediaCount: completedMediaCount ?? this.completedMediaCount,
    );
  }
}

class AppCastService extends Notifier<CastState> {
  late final dc.CastService _castService;
  StreamSubscription<List<dc.CastDevice>>? _subscription;
  StreamSubscription<dc.CastSession?>? _sessionSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<dc.SessionState>? _stateSubscription;
  bool _remoteMediaStarted = false;
  bool _remoteCompletionReported = false;
  bool _remoteMediaIsPiped = false;

  /// Offset added to the renderer's relative position for piped (HLS -> TS)
  /// DLNA routes. The renderer restarts such a stream at zero on every seek,
  /// so the absolute position is the restart point plus its reported position.
  Duration _pipedBase = Duration.zero;

  Timer? _remotePollTimer;
  bool _remotePollInFlight = false;
  DateTime? _lastRemoteReportAt;
  dc.DlnaHttpClient? _dlnaPollClient;
  dc.CastMedia? _lastCastMedia;
  Timer? _resumeVerifyTimer;

  /// Sticky position a re-point is known to be heading for.
  ///
  /// A re-pointed renderer reports its relative position from zero until the
  /// media's start position is applied, which would yank the progress bar back
  /// to the beginning. Reports below this are ignored until it is reached.
  Duration? _positionFloor;
  Timer? _positionFloorTimer;

  /// How long to wait for a requested Play to actually start playing before
  /// re-pointing the media at the last known position.
  @visibleForTesting
  Duration resumeVerifyAfter = const Duration(milliseconds: 2500);

  /// How long the active session may go without reporting before the service
  /// polls the renderer directly. dart_cast's DLNA session stops its own poll
  /// for good once the renderer reports `STOPPED` (which some renderers send
  /// transiently while seeking), so the app falls back to asking the renderer.
  @visibleForTesting
  Duration remoteReportStaleAfter = const Duration(seconds: 4);

  /// How often the service checks whether the active session has gone quiet.
  @visibleForTesting
  Duration remotePollInterval = const Duration(seconds: 1);

  @override
  CastState build() {
    _castService = dc.CastService(
      discoveryProviders: [
        dc.ChromecastDiscoveryProvider(),
        dc.AirPlayDiscoveryProvider(),
        dc.DlnaDiscoveryProvider(),
      ],
      sessionFactory: (device) {
        switch (device.protocol) {
          case dc.CastProtocol.chromecast:
            return dc.ChromecastSession(device: device);
          case dc.CastProtocol.airplay:
            return dc.AirPlaySession(device);
          case dc.CastProtocol.dlna:
            throw StateError(
              'DLNA devices require description. '
              'Use direct session creation instead.',
            );
        }
      },
    );
    logCastProcess('CastService: initialized');

    ref.onDispose(() {
      logCastProcess('CastService: disposing');
      _subscription?.cancel();
      _sessionSubscription?.cancel();
      _positionSubscription?.cancel();
      _durationSubscription?.cancel();
      _stateSubscription?.cancel();
      _stopRemotePollWatchdog();
      _resumeVerifyTimer?.cancel();
      _positionFloorTimer?.cancel();
      _dlnaPollClient?.close();
      _castService.dispose();
    });

    return CastState();
  }

  dc.CastService get castService => _castService;

  void startDiscovery() {
    logCastProcess('CastService: start discovery');
    _subscription?.cancel();
    state = state.copyWith(discoveredDevices: []);
    _subscription = _castService
        .startDiscovery(timeout: const Duration(seconds: 15))
        .listen(
          (devices) {
            logCastProcess(
              'CastService: discovered ${devices.length} device(s)',
            );
            state = state.copyWith(discoveredDevices: devices);
          },
          onDone: () {
            logCastProcess('CastService: discovery completed');
          },
          onError: (Object error) {
            logCastProcess('CastService: discovery error: $error');
          },
        );
  }

  void stopDiscovery() {
    logCastProcess('CastService: stop discovery');
    _subscription?.cancel();
    _castService.stopDiscovery();
    state = state.copyWith(discoveredDevices: []);
  }

  Future<void> loadMediaAndConfirm(
    dc.CastSession session,
    dc.CastMedia media, {
    int maxAttempts = 2,
    Duration confirmationTimeout = const Duration(milliseconds: 2500),
    Duration retryDelay = const Duration(milliseconds: 400),
  }) async {
    logCastProcess(
      'CastService: loading media device=${session.device.name} protocol=${session.device.protocol.name} type=${media.type.name} url=${media.url}',
    );
    // HLS is piped as MPEG-TS for DLNA, which restarts the pipe at the seek
    // offset; every other type is byte-seekable and reports absolute time.
    _remoteMediaIsPiped =
        session.device.protocol == dc.CastProtocol.dlna &&
        media.type == dc.CastMediaType.hls;
    _lastCastMedia = media;
    if (session.device.protocol != dc.CastProtocol.chromecast) {
      await session.loadMedia(media);
      logCastProcess(
        'CastService: media load complete device=${session.device.name}',
      );
      return;
    }

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      logCastProcess(
        'CastService: Chromecast load attempt $attempt/$maxAttempts device=${session.device.name}',
      );
      await session.loadMedia(media);
      if (await _waitForPlaybackConfirmation(session, confirmationTimeout)) {
        logCastProcess(
          'CastService: Chromecast playback confirmed device=${session.device.name} state=${session.state.name}',
        );
        return;
      }

      if (attempt < maxAttempts) {
        logCastProcess(
          'CastService: Chromecast load did not enter playback; retrying ($attempt/$maxAttempts)',
        );
        await Future<void>.delayed(retryDelay);
      }
    }

    throw TimeoutException(
      'Chromecast did not enter playback after $maxAttempts load attempts',
      confirmationTimeout * maxAttempts,
    );
  }

  Future<bool> _waitForPlaybackConfirmation(
    dc.CastSession session,
    Duration timeout,
  ) async {
    if (_isPlaybackConfirmed(session.state)) return true;
    try {
      await session.stateStream
          .where(_isPlaybackConfirmed)
          .first
          .timeout(timeout);
      return true;
    } on TimeoutException {
      return _isPlaybackConfirmed(session.state);
    }
  }

  bool _isPlaybackConfirmed(dc.SessionState state) {
    return state == dc.SessionState.playing ||
        state == dc.SessionState.buffering ||
        state == dc.SessionState.paused;
  }

  Future<void> setActiveSession(
    dc.CastSession session, {
    Duration localResumePosition = Duration.zero,
    bool localWasPlaying = false,
  }) async {
    await _sessionSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _stateSubscription?.cancel();
    _resumeVerifyTimer?.cancel();
    _clearPositionFloor();
    _remoteMediaStarted =
        session.state == dc.SessionState.playing ||
        session.state == dc.SessionState.buffering;
    _remoteCompletionReported = false;
    _pipedBase = _remoteMediaIsPiped ? localResumePosition : Duration.zero;
    _lastRemoteReportAt = DateTime.now();
    logCastProcess(
      'CastService: active session set device=${session.device.name} protocol=${session.device.protocol.name} localResumePosition=$localResumePosition localWasPlaying=$localWasPlaying',
    );
    state = state.copyWith(
      activeSession: session,
      isCasting: true,
      localResumePosition: localResumePosition,
      localWasPlaying: localWasPlaying,
      remotePosition: localResumePosition,
      remoteDuration: session.duration,
      remoteIsPlaying: true,
      remoteIsStopped: false,
    );

    _positionSubscription = session.positionStream.listen((position) {
      logCastProcess(
        'CastService: remote position updated device=${session.device.name} position=$position',
      );
      _lastRemoteReportAt = DateTime.now();
      if (_isBelowPositionFloor(position)) return;
      state = state.copyWith(remotePosition: position);
      _reportRemoteCompletionIfNeeded(session);
    });
    _durationSubscription = session.durationStream.listen((duration) {
      _lastRemoteReportAt = DateTime.now();
      state = state.copyWith(remoteDuration: duration);
      _reportRemoteCompletionIfNeeded(session);
    });
    _stateSubscription = session.stateStream.listen((sessionState) {
      logCastProcess(
        'CastService: remote state updated device=${session.device.name} state=${sessionState.name}',
      );
      _lastRemoteReportAt = DateTime.now();
      if (sessionState == dc.SessionState.playing ||
          sessionState == dc.SessionState.buffering) {
        _remoteMediaStarted = true;
        state = state.copyWith(remoteIsPlaying: true, remoteIsStopped: false);
      } else if (sessionState == dc.SessionState.paused ||
          sessionState == dc.SessionState.idle ||
          sessionState == dc.SessionState.disconnected) {
        state = state.copyWith(
          remoteIsPlaying: false,
          remoteIsStopped: sessionState == dc.SessionState.idle,
        );
      }
      _reportRemoteCompletionIfNeeded(session);
    });

    _startRemotePollWatchdog(session);
  }

  /// Starts the fallback renderer poll for [session] when it is a DLNA session.
  void _startRemotePollWatchdog(dc.CastSession session) {
    _stopRemotePollWatchdog();
    if (session is! dc.DlnaSession) return;
    _lastRemoteReportAt = DateTime.now();
    _remotePollTimer = Timer.periodic(
      remotePollInterval,
      (_) => unawaited(_pollRemoteWhenStale()),
    );
  }

  void _stopRemotePollWatchdog() {
    _remotePollTimer?.cancel();
    _remotePollTimer = null;
  }

  /// Polls the renderer only after the session has stopped reporting, so the
  /// normal poll path stays untouched.
  Future<void> _pollRemoteWhenStale() async {
    if (_remotePollInFlight) return;
    final session = state.activeSession;
    if (session is! dc.DlnaSession || !state.isCasting) return;
    final lastReport = _lastRemoteReportAt;
    if (lastReport != null &&
        DateTime.now().difference(lastReport) < remoteReportStaleAfter) {
      return;
    }
    _remotePollInFlight = true;
    try {
      await _refreshDlnaRemoteState(session);
    } finally {
      _remotePollInFlight = false;
    }
  }

  /// Reads position and transport state straight from a DLNA renderer.
  Future<void> _refreshDlnaRemoteState(dc.DlnaSession session) async {
    final controlUrl = session.description.avTransportControlUrl;
    if (controlUrl == null) return;
    final client = _dlnaPollClient ??= dc.DlnaHttpClient();
    try {
      final positionXml = await client.sendAction(
        controlUrl,
        dc.DlnaServiceType.avTransport,
        'GetPositionInfo',
        dc.DlnaSoapBuilder.buildGetPositionInfo(),
      );
      if (state.activeSession != session) return;
      final info = dc.DlnaSoapParser.parsePositionInfo(positionXml);
      final position = info.position + _pipedBase;
      // Renderers fed a piped TS report a placeholder duration; keep the value
      // the session probed from the playlist instead of clobbering it.
      if (info.duration > const Duration(seconds: 2)) {
        state = state.copyWith(remoteDuration: info.duration);
      }
      if (!_isBelowPositionFloor(position)) {
        state = state.copyWith(remotePosition: position);
      }

      final transportXml = await client.sendAction(
        controlUrl,
        dc.DlnaServiceType.avTransport,
        'GetTransportInfo',
        dc.DlnaSoapBuilder.buildGetTransportInfo(),
      );
      if (state.activeSession != session) return;
      final transportState = dc.DlnaSoapParser.parseTransportInfo(transportXml);
      final playing =
          transportState == 'PLAYING' ||
          transportState == 'BUFFERING' ||
          transportState == 'TRANSITIONING';
      if (playing) _remoteMediaStarted = true;
      final stopped =
          transportState == 'STOPPED' || transportState == 'NO_MEDIA_PRESENT';
      state = state.copyWith(
        remoteIsPlaying: playing,
        remoteIsStopped: stopped,
      );
      _reportRemoteCompletion(
        position: position,
        duration: state.remoteDuration,
        idle: stopped,
      );
      logCastProcess(
        'CastService: polled DLNA renderer device=${session.device.name} position=$position state=$transportState',
      );
    } catch (e) {
      logCastProcess(
        'CastService: DLNA renderer poll failed device=${session.device.name}: $e',
      );
    }
  }

  void _reportRemoteCompletionIfNeeded(dc.CastSession session) {
    if (state.activeSession != session) return;
    _reportRemoteCompletion(
      position: session.position,
      duration: session.duration,
      idle: session.state == dc.SessionState.idle,
    );
  }

  void _reportRemoteCompletion({
    required Duration position,
    required Duration duration,
    required bool idle,
  }) {
    if (_remoteCompletionReported || !_remoteMediaStarted) return;

    final reachedKnownEnd = duration > Duration.zero && position >= duration;
    final endedWithoutDuration = duration == Duration.zero && idle;
    if (!reachedKnownEnd && !endedWithoutDuration) return;

    _remoteCompletionReported = true;
    logCastProcess(
      'CastService: remote media completed device=${state.activeSession?.device.name}',
    );
    state = state.copyWith(
      remoteIsPlaying: false,
      completedMediaCount: state.completedMediaCount + 1,
    );
  }

  Future<void> restartActiveSessionWithMedia(
    dc.CastMedia media, {
    Duration localResumePosition = Duration.zero,
    bool localWasPlaying = false,
  }) async {
    final session = state.activeSession;
    if (session == null) return;

    await _sessionSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _stateSubscription?.cancel();

    try {
      logCastProcess(
        'CastService: restarting active session media device=${session.device.name} type=${media.type.name} url=${media.url}',
      );
      try {
        await session.disconnect();
      } catch (e) {
        logCastProcess(
          'CastService: error disconnecting previous media device=${session.device.name}: $e',
        );
      }

      await session.connect();
      logCastProcess(
        'CastService: reconnected session device=${session.device.name}',
      );
      await loadMediaAndConfirm(session, media);

      if (session.device.protocol == dc.CastProtocol.airplay &&
          localResumePosition > Duration.zero) {
        logCastProcess(
          'CastService: seeking AirPlay after restart device=${session.device.name} position=$localResumePosition',
        );
        await session.seek(localResumePosition);
      }

      await setActiveSession(
        session,
        localResumePosition: localResumePosition,
        localWasPlaying: localWasPlaying,
      );
    } catch (e) {
      logCastProcess(
        'CastService: failed to restart active session media device=${session.device.name}: $e',
      );
      _stopRemotePollWatchdog();
      _resumeVerifyTimer?.cancel();
      _clearPositionFloor();
      state = state.copyWith(
        isCasting: false,
        remotePosition: Duration.zero,
        remoteDuration: Duration.zero,
        remoteIsPlaying: false,
        remoteIsStopped: false,
        clearActiveSession: true,
        clearLocalHandoff: true,
      );
      rethrow;
    }
  }

  Future<void> stopCasting() async {
    final session = state.activeSession;
    if (session != null) {
      logCastProcess(
        'CastService: stopping session device=${session.device.name}',
      );
      try {
        await session.disconnect();
      } catch (e) {
        logCastProcess(
          'CastService: error disconnecting session device=${session.device.name}: $e',
        );
      }
    }
    await _sessionSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _stateSubscription?.cancel();
    _stopRemotePollWatchdog();
    _resumeVerifyTimer?.cancel();
    _clearPositionFloor();
    state = state.copyWith(
      isCasting: false,
      remotePosition: Duration.zero,
      remoteDuration: Duration.zero,
      remoteIsPlaying: false,
      remoteIsStopped: false,
      clearActiveSession: true,
      clearLocalHandoff: true,
    );
    logCastProcess('CastService: session stopped');
  }

  Future<void> play() async {
    final session = state.activeSession;
    if (session == null) return;
    logCastProcess(
      'CastService: play requested device=${session.device.name} remoteStopped=${state.remoteIsStopped}',
    );
    _resumeVerifyTimer?.cancel();

    // A stopped renderer has no current URI left to resume — UPnP needs the
    // media pointed at the transport again before Play means anything.
    if (state.remoteIsStopped &&
        session is dc.DlnaSession &&
        _canRepointMedia) {
      await _repointMediaAt(session, state.remotePosition);
      return;
    }

    final from = state.remotePosition;
    try {
      await session.play();
    } catch (e) {
      // Renderers answer `Play` with a SOAP error when their transport is
      // stopped or the source connection was dropped; re-point the media.
      logCastProcess(
        'CastService: play failed device=${session.device.name}: $e',
      );
      if (session is dc.DlnaSession && _canRepointMedia) {
        await _repointMediaAt(session, from);
        return;
      }
      rethrow;
    }
    _remoteMediaStarted = true;
    _remoteCompletionReported = false;
    _lastRemoteReportAt = DateTime.now();
    state = state.copyWith(remoteIsPlaying: true, remoteIsStopped: false);

    // A paused renderer can still ignore the Play (a dropped source
    // connection, a transport that quietly stopped). Confirm it really
    // resumed, and point the media at the last position if it did not.
    if (session is dc.DlnaSession && _canRepointMedia) {
      _resumeVerifyTimer = Timer(resumeVerifyAfter, () {
        if (state.activeSession != session || !state.isCasting) return;
        if (state.remoteIsPlaying && state.remotePosition > from) return;
        logCastProcess(
          'CastService: Play did not resume device=${session.device.name}; re-pointing media',
        );
        unawaited(_repointMediaAt(session, from));
      });
    }
  }

  /// Whether the media last handed to the session can be re-pointed at.
  ///
  /// Only remote URLs are re-pointable: local files and caller-supplied byte
  /// sources are registered with the session's proxy per load and cannot be
  /// reconstructed here.
  bool get _canRepointMedia {
    final media = _lastCastMedia;
    return media != null && !media.isLocalFile && media.source == null;
  }

  /// Re-loads the current media on [session], starting at [position].
  Future<void> _repointMediaAt(
    dc.DlnaSession session,
    Duration position,
  ) async {
    final media = _lastCastMedia;
    if (media == null) return;
    if (state.activeSession != session) return;
    logCastProcess(
      'CastService: re-pointing media device=${session.device.name} position=$position',
    );
    _holdPositionFloor(position);
    try {
      await session.loadMedia(_mediaAt(media, position));
    } catch (e) {
      logCastProcess(
        'CastService: re-point failed device=${session.device.name}: $e',
      );
      _clearPositionFloor();
      state = state.copyWith(remoteIsPlaying: false);
      return;
    }
    if (state.activeSession != session) return;
    _pipedBase = _remoteMediaIsPiped ? position : Duration.zero;
    _lastRemoteReportAt = DateTime.now();
    _remoteMediaStarted = true;
    _remoteCompletionReported = false;
    state = state.copyWith(
      remotePosition: position,
      remoteIsPlaying: true,
      remoteIsStopped: false,
    );
  }

  /// Copies [media], overriding only the playback start position.
  dc.CastMedia _mediaAt(dc.CastMedia media, Duration position) {
    return dc.CastMedia(
      url: media.url,
      type: media.type,
      httpHeaders: media.httpHeaders,
      title: media.title,
      imageUrl: media.imageUrl,
      duration: media.duration,
      subtitles: media.subtitles,
      defaultSubtitle: media.defaultSubtitle,
      startPosition: position > Duration.zero ? position : null,
    );
  }

  /// Ignores renderer reports that sit behind an in-flight re-point.
  bool _isBelowPositionFloor(Duration position) {
    final floor = _positionFloor;
    if (floor == null) return false;
    if (position + const Duration(seconds: 2) < floor) return true;
    _clearPositionFloor();
    return false;
  }

  void _holdPositionFloor(Duration position) {
    _positionFloor = position;
    _positionFloorTimer?.cancel();
    _positionFloorTimer = Timer(
      const Duration(seconds: 10),
      _clearPositionFloor,
    );
  }

  void _clearPositionFloor() {
    _positionFloorTimer?.cancel();
    _positionFloorTimer = null;
    _positionFloor = null;
  }

  Future<void> pause() async {
    final session = state.activeSession;
    if (session == null) return;
    logCastProcess(
      'CastService: pause requested device=${session.device.name}',
    );
    _resumeVerifyTimer?.cancel();
    await session.pause();
    state = state.copyWith(remoteIsPlaying: false, remoteIsStopped: false);
  }

  Future<void> seek(Duration position) async {
    final session = state.activeSession;
    if (session == null) return;
    final wasPlaying = state.remoteIsPlaying;
    logCastProcess(
      'CastService: seek requested device=${session.device.name} position=$position wasPlaying=$wasPlaying',
    );
    _resumeVerifyTimer?.cancel();
    _clearPositionFloor();
    await session.seek(position);
    if (_remoteMediaIsPiped) _pipedBase = position;
    _lastRemoteReportAt = DateTime.now();
    state = state.copyWith(remotePosition: position);
    if (!wasPlaying) {
      // Seeking must not change whether the remote is playing, but renderers
      // commonly resume on a seek: DLNA's piped-TS route re-issues Play after
      // every seek, and byte-seekable renderers often come back PLAYING too.
      await pause();
    }
  }
}

final castServiceProvider = NotifierProvider<AppCastService, CastState>(
  AppCastService.new,
);

dc.CastMediaType detectCastMediaType(String url) {
  final lower = url.toLowerCase();
  if (lower.contains('.m3u8') || lower.contains('hls')) {
    return dc.CastMediaType.hls;
  }
  if (lower.contains('.ts')) {
    return dc.CastMediaType.mpegTs;
  }
  if (lower.contains('.mkv')) {
    return dc.CastMediaType.mkv;
  }
  return dc.CastMediaType.mp4;
}
