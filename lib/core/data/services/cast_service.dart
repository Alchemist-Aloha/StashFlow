import 'dart:async';
import 'package:dart_cast/dart_cast.dart' as dc;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CastState {
  final List<dc.CastDevice> discoveredDevices;
  final dc.CastSession? activeSession;
  final bool isCasting;

  CastState({
    this.discoveredDevices = const [],
    this.activeSession,
    this.isCasting = false,
  });

  CastState copyWith({
    List<dc.CastDevice>? discoveredDevices,
    dc.CastSession? activeSession,
    bool? isCasting,
  }) {
    return CastState(
      discoveredDevices: discoveredDevices ?? this.discoveredDevices,
      activeSession: activeSession ?? this.activeSession,
      isCasting: isCasting ?? this.isCasting,
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

  Future<void> setActiveSession(dc.CastSession session) async {
    await _sessionSubscription?.cancel();
    state = state.copyWith(activeSession: session, isCasting: true);
    
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
    state = state.copyWith(activeSession: null, isCasting: false);
  }

  Future<void> play() async {
    await state.activeSession?.play();
  }

  Future<void> pause() async {
    await state.activeSession?.pause();
  }

  Future<void> seek(Duration position) async {
    await state.activeSession?.seek(position);
  }

  Future<Duration> getRemotePosition() async {
    // Some protocols might support getting the current position
    // For now we might have to rely on local tracking or session state
    return Duration.zero; 
  }
}

final castServiceProvider = NotifierProvider<AppCastService, CastState>(
  AppCastService.new,
);
