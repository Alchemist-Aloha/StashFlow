import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/error_state_view.dart';
import '../../../../core/presentation/widgets/section_header.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../providers/group_details_provider.dart';
import '../providers/group_list_provider.dart';

class GroupDetailsPage extends ConsumerWidget {
  final String groupId;

  const GroupDetailsPage({required this.groupId, super.key});

  Widget _buildSectionContainer(BuildContext context, Widget child) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withValues(
        alpha: 0.1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusExtraLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupDetailsProvider(groupId));

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.details_group)),
      body: groupAsync.when(
        data: (group) => RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(groupRepositoryProvider)
                .getGroupById(groupId, refresh: true);
            ref.invalidate(groupDetailsProvider(groupId));
            return ref.read(groupDetailsProvider(groupId).future);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                      color: context.colors.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name.isEmpty
                            ? context.l10n.groups_untitled
                            : group.name,
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
                          if (group.date != null)
                            _buildChip(context, group.date!),
                          if (group.director != null &&
                              group.director!.isNotEmpty)
                            _buildChip(context, group.director!),
                          if (group.rating100 != null)
                            _buildChip(
                              context,
                              (group.rating100! / 20).toStringAsFixed(1),
                              icon: Icons.star,
                              iconColor: context.colors.ratingColor,
                            ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),
                      if (group.synopsis != null &&
                          group.synopsis!.isNotEmpty) ...[
                        _buildSectionContainer(
                          context,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SectionHeader(
                                title: context.l10n.details_synopsis,
                                padding: EdgeInsets.zero,
                              ),
                              const SizedBox(height: AppTheme.spacingSmall),
                              Text(
                                group.synopsis!,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.colors.onSurface.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorStateView(
          message: context.l10n.common_error(err.toString()),
          onRetry: () => ref.refresh(groupDetailsProvider(groupId)),
        ),
      ),
    );
  }

  Widget _buildChip(
    BuildContext context,
    String label, {
    IconData? icon,
    Color? iconColor,
  }) {
    return Chip(
      avatar: icon != null
          ? Icon(
              icon,
              size: 16,
              color: iconColor ?? context.colors.onSurfaceVariant,
            )
          : null,
      label: Text(label, style: context.textTheme.bodySmall),
      backgroundColor: context.colors.surfaceVariant,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}
