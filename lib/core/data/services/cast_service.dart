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
  final bool remoteIsPlaying;

  CastState({
    this.discoveredDevices = const [],
    this.activeSession,
    this.isCasting = false,
    this.localResumePosition,
    this.localWasPlaying = false,
    this.remotePosition = Duration.zero,
    this.remoteIsPlaying = false,
  });

  CastState copyWith({
    List<dc.CastDevice>? discoveredDevices,
    dc.CastSession? activeSession,
    bool? isCasting,
    Duration? localResumePosition,
    bool? localWasPlaying,
    Duration? remotePosition,
    bool? remoteIsPlaying,
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
      remoteIsPlaying: remoteIsPlaying ?? this.remoteIsPlaying,
    );
  }
}

class AppCastService extends Notifier<CastState> {
  late final dc.CastService _castService;
  StreamSubscription<List<dc.CastDevice>>? _subscription;
  StreamSubscription<dc.CastSession?>? _sessionSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<dc.SessionState>? _stateSubscription;

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
      _stateSubscription?.cancel();
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
          onError: (error) {
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
    await _stateSubscription?.cancel();
    logCastProcess(
      'CastService: active session set device=${session.device.name} protocol=${session.device.protocol.name} localResumePosition=$localResumePosition localWasPlaying=$localWasPlaying',
    );
    state = state.copyWith(
      activeSession: session,
      isCasting: true,
      localResumePosition: localResumePosition,
      localWasPlaying: localWasPlaying,
      remotePosition: localResumePosition,
      remoteIsPlaying: true,
    );

    _positionSubscription = session.positionStream.listen((position) {
      logCastProcess(
        'CastService: remote position updated device=${session.device.name} position=$position',
      );
      state = state.copyWith(remotePosition: position);
    });
    _stateSubscription = session.stateStream.listen((sessionState) {
      logCastProcess(
        'CastService: remote state updated device=${session.device.name} state=${sessionState.name}',
      );
      if (sessionState == dc.SessionState.playing ||
          sessionState == dc.SessionState.buffering) {
        state = state.copyWith(remoteIsPlaying: true);
      } else if (sessionState == dc.SessionState.paused ||
          sessionState == dc.SessionState.idle ||
          sessionState == dc.SessionState.disconnected) {
        state = state.copyWith(remoteIsPlaying: false);
      }
    });
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
      state = state.copyWith(
        isCasting: false,
        remotePosition: Duration.zero,
        remoteIsPlaying: false,
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
    await _stateSubscription?.cancel();
    state = state.copyWith(
      isCasting: false,
      remotePosition: Duration.zero,
      remoteIsPlaying: false,
      clearActiveSession: true,
      clearLocalHandoff: true,
    );
    logCastProcess('CastService: session stopped');
  }

  Future<void> play() async {
    final session = state.activeSession;
    if (session == null) return;
    logCastProcess('CastService: play requested device=${session.device.name}');
    await session.play();
    state = state.copyWith(remoteIsPlaying: true);
  }

  Future<void> pause() async {
    final session = state.activeSession;
    if (session == null) return;
    logCastProcess(
      'CastService: pause requested device=${session.device.name}',
    );
    await session.pause();
    state = state.copyWith(remoteIsPlaying: false);
  }

  Future<void> seek(Duration position) async {
    final session = state.activeSession;
    if (session == null) return;
    logCastProcess(
      'CastService: seek requested device=${session.device.name} position=$position',
    );
    await session.seek(position);
    state = state.copyWith(remotePosition: position);
  }

  Future<Duration> getRemotePosition() async {
    return state.remotePosition;
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
