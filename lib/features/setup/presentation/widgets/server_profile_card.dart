import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import '../../domain/models/server_profile.dart';
import '../providers/connection_provider.dart';
import '../providers/server_profiles_provider.dart';

class ServerProfileCard extends ConsumerWidget {
  final ServerProfile profile;
  final VoidCallback onEdit;

  const ServerProfileCard({
    super.key,
    required this.profile,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final activeId = ref.watch(activeServerProfileIdProvider);
    final isActive = activeId == profile.id;
    final connectionStatus = ref.watch(connectionStatusProvider(profile));

    return Card(
      elevation: isActive ? 4 : 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isActive
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          ref.read(activeServerProfileIdProvider.notifier).set(profile.id);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildActiveIndicator(context, isActive),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name ?? profile.baseUrl,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.baseUrl,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _buildStatusRow(context, connectionStatus, l10n),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: onEdit,
                tooltip: l10n.common_edit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveIndicator(BuildContext context, bool isActive) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
          width: 2,
        ),
        color: isActive ? Theme.of(context).colorScheme.primary : null,
      ),
      child: isActive
          ? Icon(
              Icons.check,
              size: 16,
              color: Theme.of(context).colorScheme.onPrimary,
            )
          : null,
    );
  }

  Widget _buildStatusRow(
      BuildContext context, AsyncValue<String> status, AppLocalizations l10n) {
    return Row(
      children: [
        status.when(
          data: (version) => Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Colors.green[700],
          ),
          loading: () => const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          error: (_, _) => Icon(
            Icons.error_outline,
            size: 16,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            status.when(
              data: (version) => version,
              loading: () => l10n.settings_server_checking,
              error: (e, _) => l10n.settings_server_failed(e.toString()),
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: status.when(
                    data: (_) => Colors.green[700],
                    loading: () => null,
                    error: (_, _) => Theme.of(context).colorScheme.error,
                  ),                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
