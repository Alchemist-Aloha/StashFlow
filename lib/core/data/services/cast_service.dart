import 'dart:async';
import 'package:dart_cast/dart_cast.dart' as dc;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppCastService extends Notifier<List<dc.CastDevice>> {
  late final dc.CastService _castService;
  StreamSubscription<List<dc.CastDevice>>? _subscription;

  @override
  List<dc.CastDevice> build() {
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

    ref.onDispose(() {
      _subscription?.cancel();
      _castService.dispose();
    });

    return [];
  }

  dc.CastService get castService => _castService;

  void startDiscovery() {
    _subscription?.cancel();
    state = [];
    _subscription = _castService
        .startDiscovery(timeout: const Duration(seconds: 15))
        .listen(
      (devices) {
        state = devices;
      },
      onDone: () {},
      onError: (error) {},
    );
  }

  void stopDiscovery() {
    _subscription?.cancel();
    _castService.stopDiscovery();
    state = [];
  }
}

final castServiceProvider = NotifierProvider<AppCastService, List<dc.CastDevice>>(
  AppCastService.new,
);
