import '../../providers/video_player_provider.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';
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
      if (!mounted) return;
      logCastProcess(
        'CastSelectionSheet: start discovery',
        source: 'cast_selection_sheet',
      );
      ref.read(castServiceProvider.notifier).startDiscovery();
    });
  }

  void _showConnectingDialog(String deviceName) {
    if (mounted) {
      final message = context.l10n.cast_connecting_to(deviceName);
      logCastProcess(
        'CastSelectionSheet: connecting to $deviceName',
        source: 'cast_selection_sheet',
      );
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 24),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
    }
  }

  void _dismissConnectingDialog(NavigatorState navigator) {
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  Future<String?> _showPinDialog() {
    final pinController = TextEditingController();
    return () async {
      try {
        return await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: Text(context.l10n.cast_airplay_pairing),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.l10n.cast_enter_pin),
                const SizedBox(height: 16),
                TextField(
                  textInputAction: TextInputAction.next,
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
                child: Text(context.l10n.common_cancel),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.of(dialogContext).pop(pinController.text),
                child: Text(context.l10n.cast_pair),
              ),
            ],
          ),
        );
      } finally {
        pinController.dispose();
      }
    }();
  }

  Future<void> _connectToDevice(dc.CastDevice device) async {
    logCastProcess(
      'CastSelectionSheet: selected ${device.name} (${device.protocol.name})',
      source: 'cast_selection_sheet',
    );
    // Show a connecting dialog
    _showConnectingDialog(device.name);
    var connectingDialogVisible = true;

    final rootNavigator = Navigator.of(context, rootNavigator: true);
    final sheetNavigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final errorColor = context.colors.error;
    final appCastServiceNotifier = ref.read(castServiceProvider.notifier);
    final playerStateNotifier = ref.read(playerStateProvider.notifier);
    final playerState = ref.read(playerStateProvider);
    final localPlayer = playerState.player;
    final currentPos = localPlayer?.state.position ?? Duration.zero;
    final localWasPlaying = localPlayer?.state.playing ?? false;
    if (localWasPlaying) {
      playerStateNotifier.pause();
    }
    void dismissConnectingDialog() {
      if (!connectingDialogVisible) return;
      _dismissConnectingDialog(rootNavigator);
      connectingDialogVisible = false;
    }

    try {
      dc.CastSession session;

      if (device.protocol == dc.CastProtocol.dlna) {
        logCastProcess(
          'CastSelectionSheet: using DLNA session',
          source: 'cast_selection_sheet',
        );
        session = dc.DlnaSession.fromDevice(device);
        await session.connect();
      } else {
        logCastProcess(
          'CastSelectionSheet: connecting via castService',
          source: 'cast_selection_sheet',
        );
        session = await appCastServiceNotifier.castService.connect(device);
      }

      // Close the connecting dialog
      dismissConnectingDialog();

      // Load media
      final mediaType = detectCastMediaType(widget.videoUrl);
      logCastProcess(
        'CastSelectionSheet: loading media type ${mediaType.name} url=${widget.videoUrl}',
        source: 'cast_selection_sheet',
      );
      final media = dc.CastMedia(
        url: widget.videoUrl,
        type: mediaType,
        title: widget.title,
        startPosition: currentPos > Duration.zero ? currentPos : null,
      );

      await appCastServiceNotifier.loadMediaAndConfirm(session, media);

      if (device.protocol == dc.CastProtocol.airplay &&
          currentPos > Duration.zero) {
        logCastProcess(
          'CastSelectionSheet: seeking cast to $currentPos',
          source: 'cast_selection_sheet',
        );
        await session.seek(currentPos);
      }

      await appCastServiceNotifier.setActiveSession(
        session,
        localResumePosition: currentPos,
        localWasPlaying: localWasPlaying,
      );
      logCastProcess(
        'CastSelectionSheet: load media complete',
        source: 'cast_selection_sheet',
      );

      if (mounted) {
        sheetNavigator.pop();
      }
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.cast_casting_to(device.name))),
      );
    } on dc.NeedsPairingException catch (_) {
      logCastProcess(
        'CastSelectionSheet: AirPlay pairing required',
        source: 'cast_selection_sheet',
      );
      // Dismiss connecting dialog
      dismissConnectingDialog();

      // Trigger PIN display on TV
      dc.AirPlayPairSetup(
        host: device.address.address,
        port: device.port,
      ).startPinDisplay();

      // Show PIN dialog
      final pin = await _showPinDialog();
      if (pin != null && pin.length == 4) {
        logCastProcess(
          'CastSelectionSheet: pairing with PIN',
          source: 'cast_selection_sheet',
        );
        // Re-show connecting dialog
        _showConnectingDialog(device.name);
        connectingDialogVisible = true;
        try {
          // Create a fresh AirPlaySession for pairing
          final session = dc.AirPlaySession(device);
          await session.pairSetup(pin);
          // Retry connect with the newly stored credentials
          await session.connect();

          final mediaType = detectCastMediaType(widget.videoUrl);
          logCastProcess(
            'CastSelectionSheet: loading media type ${mediaType.name} url=${widget.videoUrl}',
            source: 'cast_selection_sheet',
          );
          final media = dc.CastMedia(
            url: widget.videoUrl,
            type: mediaType,
            title: widget.title,
            startPosition: currentPos > Duration.zero ? currentPos : null,
          );
          await appCastServiceNotifier.loadMediaAndConfirm(session, media);

          if (currentPos > Duration.zero) {
            logCastProcess(
              'CastSelectionSheet: seeking cast to $currentPos',
              source: 'cast_selection_sheet',
            );
            await session.seek(currentPos);
          }

          await appCastServiceNotifier.setActiveSession(
            session,
            localResumePosition: currentPos,
            localWasPlaying: localWasPlaying,
          );
          logCastProcess(
            'CastSelectionSheet: load media complete',
            source: 'cast_selection_sheet',
          );

          // Dismiss connecting dialog
          dismissConnectingDialog();

          if (mounted) {
            sheetNavigator.pop();
          }
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.cast_casting_to(device.name))),
          );
        } catch (e) {
          logCastProcess(
            'CastSelectionSheet: pairing failed: $e',
            source: 'cast_selection_sheet',
          );
          // Dismiss connecting dialog
          dismissConnectingDialog();
          if (localWasPlaying) {
            playerStateNotifier.play();
          }

          messenger.showSnackBar(
            SnackBar(content: Text(l10n.cast_pairing_failed(e.toString()))),
          );
        }
      } else if (localWasPlaying) {
        playerStateNotifier.play();
      }
    } catch (e) {
      logCastProcess(
        'CastSelectionSheet: cast failed: $e',
        source: 'cast_selection_sheet',
      );
      // Dismiss connecting dialog
      dismissConnectingDialog();
      if (localWasPlaying) {
        playerStateNotifier.play();
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.cast_failed_to_cast(e.toString())),
          backgroundColor: errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final castState = ref.watch(castServiceProvider);
    final devices = castState.discoveredDevices;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom + AppTheme.spacingMedium,
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
                  context.l10n.cast_cast_to_device,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: context.l10n.common_refresh,
                  onPressed: () {
                    logCastProcess(
                      'CastSelectionSheet: refresh discovery',
                      source: 'cast_selection_sheet',
                    );
                    ref.read(castServiceProvider.notifier).startDiscovery();
                  },
                ),
              ],
            ),
          ),
          if (devices.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(context.l10n.cast_searching),
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
