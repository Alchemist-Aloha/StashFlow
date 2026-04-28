import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/services/cast_service.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/utils/l10n_extensions.dart';

/// A bottom sheet that allows users to select a DLNA device for casting.
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
                  return ListTile(
                    leading: const Icon(Icons.tv),
                    title: Text(device.info.friendlyName),
                    subtitle: Text(device.info.modelName ?? 'UPnP/DLNA Device'),
                    onTap: () async {
                      try {
                        // Stop local playback before starting cast.
                        // We assume the caller handles local player state.
                        await device.setAVTransportURI(
                          widget.videoUrl,
                          widget.title,
                        );
                        await device.play();
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Casting to ${device.info.friendlyName}'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to cast: $e'),
                              backgroundColor: context.colors.error,
                            ),
                          );
                        }
                      }
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
