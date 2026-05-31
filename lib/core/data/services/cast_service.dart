import 'dart:async';
import 'package:dart_cast/dart_cast.dart' as dc;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    debugPrint('CastService: initialized');

    ref.onDispose(() {
      debugPrint('CastService: disposing');
      _subscription?.cancel();
      _sessionSubscription?.cancel();
      _castService.dispose();
    });

    return CastState();
  }

  dc.CastService get castService => _castService;

  void startDiscovery() {
    debugPrint('CastService: start discovery');
    _subscription?.cancel();
    state = state.copyWith(discoveredDevices: []);
    _subscription = _castService
        .startDiscovery(timeout: const Duration(seconds: 15))
        .listen(
          (devices) {
            debugPrint('CastService: discovered ${devices.length} device(s)');
            state = state.copyWith(discoveredDevices: devices);
          },
          onDone: () {
            debugPrint('CastService: discovery completed');
          },
          onError: (error) {
            debugPrint('CastService: discovery error: $error');
          },
        );
  }

  void stopDiscovery() {
    debugPrint('CastService: stop discovery');
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
    if (session.device.protocol != dc.CastProtocol.chromecast) {
      await session.loadMedia(media);
      return;
    }

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      await session.loadMedia(media);
      if (await _waitForPlaybackConfirmation(session, confirmationTimeout)) {
        return;
      }

      if (attempt < maxAttempts) {
        debugPrint(
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
    state = state.copyWith(
      activeSession: session,
      isCasting: true,
      localResumePosition: localResumePosition,
      localWasPlaying: localWasPlaying,
      remotePosition: localResumePosition,
      remoteIsPlaying: true,
    );

    // We can add session listeners here if dart_cast supports them
  }

  Future<void> stopCasting() async {
    final session = state.activeSession;
    if (session != null) {
      debugPrint('CastService: stopping session');
      try {
        await session.disconnect();
      } catch (e) {
        debugPrint('CastService: error disconnecting session: $e');
      }
    }
    await _sessionSubscription?.cancel();
    state = state.copyWith(
      isCasting: false,
      remotePosition: Duration.zero,
      remoteIsPlaying: false,
      clearActiveSession: true,
      clearLocalHandoff: true,
    );
  }

  Future<void> play() async {
    final session = state.activeSession;
    if (session == null) return;
    await session.play();
    state = state.copyWith(remoteIsPlaying: true);
  }

  Future<void> pause() async {
    final session = state.activeSession;
    if (session == null) return;
    await session.pause();
    state = state.copyWith(remoteIsPlaying: false);
  }

  Future<void> seek(Duration position) async {
    final session = state.activeSession;
    if (session == null) return;
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
