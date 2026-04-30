import 'package:dart_cast/dart_cast.dart' as dc;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/data/services/cast_service.dart';
import '../../../../../core/presentation/theme/app_theme.dart';
import '../../providers/video_player_provider.dart';

/// A bottom sheet that allows users to select a device for casting.
class CastSelectionSheet extends ConsumerStatefulWidget {
  final String videoUrl;
  final String title;

  const CastSelectionSheet({
    required this.videoUrl,
    required this.title,
    super.key,
  });

  @override
  ConsumerState<CastSelectionSheet> createState() => _CastSelectionSheetState();
}

class _CastSelectionSheetState extends ConsumerState<CastSelectionSheet> {
  @override
  void initState() {
    super.initState();
    // Start discovery when the sheet is opened.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('CastSelectionSheet: start discovery');
      ref.read(castServiceProvider.notifier).startDiscovery();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showConnectingDialog(String deviceName) {
    if (mounted) {
      debugPrint('CastSelectionSheet: connecting to $deviceName');
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 24),
              Expanded(
                child: Text('Connecting to $deviceName...'),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<String?> _showPinDialog() {
    final pinController = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('AirPlay Pairing'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the 4-digit PIN shown on your TV'),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              autofocus: true,
              maxLength: 4,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: const InputDecoration(
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(pinController.text),
            child: const Text('Pair'),
          ),
        ],
      ),
    );
  }

  Future<void> _connectToDevice(dc.CastDevice device) async {
    debugPrint(
      'CastSelectionSheet: selected ${device.name} (${device.protocol.name})',
    );
    // Show a connecting dialog
    _showConnectingDialog(device.name);

    final appCastServiceNotifier = ref.read(castServiceProvider.notifier);

    try {
      dc.CastSession session;

      if (device.protocol == dc.CastProtocol.dlna) {
        debugPrint('CastSelectionSheet: using DLNA session');
        session = dc.DlnaSession.fromDevice(device);
        await session.connect();
      } else {
        debugPrint('CastSelectionSheet: connecting via castService');
        session = await appCastServiceNotifier.castService.connect(device);
      }

      // Close the connecting dialog
      if (mounted) Navigator.of(context).pop();

      // Load media
      final mediaType = _detectMediaType(widget.videoUrl);
      debugPrint(
        'CastSelectionSheet: loading media type ${mediaType.name} url=${widget.videoUrl}',
      );
      final media = dc.CastMedia(
        url: widget.videoUrl,
        type: mediaType,
        title: widget.title,
      );

      await session.loadMedia(media);
      
      // Get current local position to sync
      final playerState = ref.read(playerStateProvider);
      final currentPos = playerState.player?.state.position ?? Duration.zero;
      if (currentPos > Duration.zero) {
        debugPrint('CastSelectionSheet: seeking cast to $currentPos');
        await session.seek(currentPos);
      }

      await appCastServiceNotifier.setActiveSession(session);
      debugPrint('CastSelectionSheet: load media complete');

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Casting to ${device.name}'),
          ),
        );
      }
    } on dc.NeedsPairingException catch (_) {
      debugPrint('CastSelectionSheet: AirPlay pairing required');
      // Dismiss connecting dialog
      if (mounted) Navigator.of(context).pop();

      // Trigger PIN display on TV
      dc.AirPlayPairSetup(host: device.address.address, port: device.port)
          .startPinDisplay();

      // Show PIN dialog
      final pin = await _showPinDialog();
      if (pin != null && pin.length == 4) {
        debugPrint('CastSelectionSheet: pairing with PIN');
        // Re-show connecting dialog
        _showConnectingDialog(device.name);
        try {
          // Create a fresh AirPlaySession for pairing
          final session = dc.AirPlaySession(device);
          await session.pairSetup(pin);
          // Retry connect with the newly stored credentials
          await session.connect();

          final mediaType = _detectMediaType(widget.videoUrl);
          debugPrint(
            'CastSelectionSheet: loading media type ${mediaType.name} url=${widget.videoUrl}',
          );
          final media = dc.CastMedia(
            url: widget.videoUrl,
            type: mediaType,
            title: widget.title,
          );
          await session.loadMedia(media);

          // Get current local position to sync
          final playerState = ref.read(playerStateProvider);
          final currentPos = playerState.player?.state.position ?? Duration.zero;
          if (currentPos > Duration.zero) {
            debugPrint('CastSelectionSheet: seeking cast to $currentPos');
            await session.seek(currentPos);
          }

          await appCastServiceNotifier.setActiveSession(session);
          debugPrint('CastSelectionSheet: load media complete');

          // Dismiss connecting dialog
          if (mounted) Navigator.of(context).pop();

          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Casting to ${device.name}'),
              ),
            );
          }
        } catch (e) {
          debugPrint('CastSelectionSheet: pairing failed: $e');
          // Dismiss connecting dialog
          if (mounted) Navigator.of(context).pop();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Pairing failed: $e')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('CastSelectionSheet: cast failed: $e');
      // Dismiss connecting dialog
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cast: $e'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  dc.CastMediaType _detectMediaType(String url) {
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

  @override
  Widget build(BuildContext context) {
    final castState = ref.watch(castServiceProvider);
    final devices = castState.discoveredDevices;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + AppTheme.spacingMedium,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cast to Device',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                    onPressed: () {
                      debugPrint('CastSelectionSheet: refresh discovery');
                      ref
                          .read(castServiceProvider.notifier)
                          .startDiscovery();
                    },
                ),
              ],
            ),
          ),
          if (devices.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Searching for devices...'),
                  ],
                ),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  IconData iconData;
                  switch (device.protocol) {
                    case dc.CastProtocol.chromecast:
                      iconData = Icons.cast;
                      break;
                    case dc.CastProtocol.airplay:
                      iconData = Icons.airplay;
                      break;
                    case dc.CastProtocol.dlna:
                      iconData = Icons.tv;
                      break;
                  }

                  return ListTile(
                    leading: Icon(iconData),
                    title: Text(device.name),
                    subtitle: Text(device.protocol.name.toUpperCase()),
                    onTap: () => _connectToDevice(device),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
