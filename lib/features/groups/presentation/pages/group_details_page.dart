import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/error_state_view.dart';
import '../../../../core/presentation/widgets/section_header.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../providers/group_details_provider.dart';

class GroupDetailsPage extends ConsumerWidget {
  final String groupId;

  const GroupDetailsPage({required this.groupId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupDetailsProvider(groupId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Details'),
      ),
      body: groupAsync.when(
        data: (group) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 240,
                width: double.infinity,
                color: context.colors.surfaceVariant,
                child: Center(
                  child: Icon(
                    Icons.group_work,
                    size: 72,
                    color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name.isEmpty ? 'Untitled group' : group.name,
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),
                    Wrap(
                      spacing: AppTheme.spacingSmall,
                      runSpacing: AppTheme.spacingSmall,
                      children: [
                        if (group.date != null) _buildChip(context, group.date!),
                        if (group.director != null && group.director!.isNotEmpty) _buildChip(context, 'Director: ${group.director}'),
                        if (group.rating100 != null)
                          _buildChip(
                            context,
                            'Rating: ${(group.rating100! / 20).toStringAsFixed(1)}',
                            icon: Icons.star,
                            iconColor: context.colors.ratingColor,
                          ),
                      ],
                    ),
                    if (group.synopsis != null && group.synopsis!.isNotEmpty) ...[
                      const Divider(height: 32, color: Colors.grey),
                      const SectionHeader(title: 'Synopsis', padding: EdgeInsets.zero),
                      const SizedBox(height: AppTheme.spacingSmall),
                      Text(
                        group.synopsis!,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorStateView(
          message: 'Failed to load group details.\n$err',
          onRetry: () => ref.refresh(groupDetailsProvider(groupId)),
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, {IconData? icon, Color? iconColor}) {
    return Chip(
      avatar: icon != null ? Icon(icon, size: 16, color: iconColor ?? context.colors.onSurfaceVariant) : null,
      label: Text(label, style: context.textTheme.bodySmall),
      backgroundColor: context.colors.surfaceVariant,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}
