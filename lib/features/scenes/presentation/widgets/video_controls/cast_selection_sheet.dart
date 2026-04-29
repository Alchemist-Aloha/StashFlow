import 'package:dart_cast/dart_cast.dart' as dc;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/data/services/cast_service.dart';
import '../../../../../core/presentation/theme/app_theme.dart';

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
      ref.read(castServiceProvider.notifier).startDiscovery();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showConnectingDialog(String deviceName) {
    if (mounted) {
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
    // Show a connecting dialog
    _showConnectingDialog(device.name);

    final appCastService = ref.read(castServiceProvider.notifier);

    try {
      dc.CastSession session;

      if (device.protocol == dc.CastProtocol.dlna) {
        session = dc.DlnaSession.fromDevice(device);
        await session.connect();
      } else {
        session = await appCastService.castService.connect(device);
      }

      // Close the connecting dialog
      if (mounted) Navigator.of(context).pop();

      // Load media
      final mediaType = _detectMediaType(widget.videoUrl);
      final media = dc.CastMedia(
        url: widget.videoUrl,
        type: mediaType,
        title: widget.title,
      );

      await session.loadMedia(media);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Casting to ${device.name}'),
          ),
        );
      }
    } on dc.NeedsPairingException catch (_) {
      // Dismiss connecting dialog
      if (mounted) Navigator.of(context).pop();

      // Trigger PIN display on TV
      dc.AirPlayPairSetup(host: device.address.address, port: device.port)
          .startPinDisplay();

      // Show PIN dialog
      final pin = await _showPinDialog();
      if (pin != null && pin.length == 4) {
        // Re-show connecting dialog
        _showConnectingDialog(device.name);
        try {
          // Create a fresh AirPlaySession for pairing
          final session = dc.AirPlaySession(device);
          await session.pairSetup(pin);
          // Retry connect with the newly stored credentials
          await session.connect();

          final mediaType = _detectMediaType(widget.videoUrl);
          final media = dc.CastMedia(
            url: widget.videoUrl,
            type: mediaType,
            title: widget.title,
          );
          await session.loadMedia(media);

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
    final devices = ref.watch(castServiceProvider);

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
                  onPressed: () =>
                      ref.read(castServiceProvider.notifier).startDiscovery(),
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
