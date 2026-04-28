import 'dart:async';
import 'package:dlna_dart/dlna.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A service that manages the discovery and life-cycle of DLNA/UPnP devices.
///
/// This provider uses [dlna_dart] to scan the local network for compatible
/// media players and provides a list of discovered devices.
class CastService extends Notifier<List<DLNADevice>> {
  final _manager = DLNAManager();
  StreamSubscription? _subscription;
  DeviceManager? _deviceManager;

  @override
  List<DLNADevice> build() {
    // Automatically stop searching when the provider is disposed.
    ref.onDispose(() {
      _subscription?.cancel();
      _manager.stop();
    });

    return [];
  }

  /// Starts searching for DLNA devices on the local network.
  Future<void> startDiscovery() async {
    _subscription?.cancel();
    _deviceManager = await _manager.start();
    _subscription = _deviceManager?.devices.stream.listen((deviceMap) {
      state = deviceMap.values.toList();
    });
  }

  /// Stops any active DLNA discovery processes.
  void stopDiscovery() {
    _subscription?.cancel();
    _manager.stop();
    state = [];
  }
}

/// Provider for the list of discovered DLNA devices.
final castServiceProvider = NotifierProvider<CastService, List<DLNADevice>>(
  CastService.new,
);
