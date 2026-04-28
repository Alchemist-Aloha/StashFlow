import 'package:dlna_dart/dlna_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A service that manages the discovery and life-cycle of DLNA/UPnP devices.
///
/// This provider uses [dlna_dart] to scan the local network for compatible
/// media players and provides a list of discovered devices.
class CastService extends Notifier<List<DLNADevice>> {
  final _manager = DLNAManager();

  @override
  List<DLNADevice> build() {
    _manager.setRefreshedCallback(() {
      if (mounted) {
        state = _manager.devices.values.toList();
      }
    });

    // Automatically stop searching when the provider is disposed.
    ref.onDispose(() {
      _manager.stopSearch();
    });

    return [];
  }

  /// Forces a fresh search for DLNA devices on the local network.
  void startDiscovery() {
    _manager.forceSearch();
  }

  /// Stops any active DLNA discovery processes.
  void stopDiscovery() {
    _manager.stopSearch();
  }
}

/// Provider for the list of discovered DLNA devices.
final castServiceProvider = NotifierProvider<CastService, List<DLNADevice>>(
  CastService.new,
);
