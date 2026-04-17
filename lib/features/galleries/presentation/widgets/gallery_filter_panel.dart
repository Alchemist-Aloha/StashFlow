import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/gallery_filter.dart';
import '../providers/gallery_list_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';

class GalleryFilterPanel extends ConsumerStatefulWidget {
  const GalleryFilterPanel({super.key});

  @override
  ConsumerState<GalleryFilterPanel> createState() => _GalleryFilterPanelState();
}

class _GalleryFilterPanelState extends ConsumerState<GalleryFilterPanel> {
  late GalleryFilter _tempFilter;
  late bool _tempOrganizedOnly;

  @override
  void initState() {
    super.initState();
    _tempFilter = ref.read(galleryFilterStateProvider);
    _tempOrganizedOnly = ref.read(galleryOrganizedOnlyProvider);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      top: false,
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusExtraLarge),
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: bottomInset + safeBottom + AppTheme.spacingLarge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Galleries',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _tempFilter = GalleryFilter.empty();
                          _tempOrganizedOnly = false;
                        });
                      },
                      child: Text(context.l10n.common_reset),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                Text('Minimum Rating', style: context.textTheme.labelLarge),
                const SizedBox(height: AppTheme.spacingSmall),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    ChoiceChip(
                      label: const Text('Any'),
                      selected: _tempFilter.minRating == null,
                      onSelected: (_) {
                        setState(
                          () => _tempFilter = _tempFilter.copyWith(
                            minRating: null,
                          ),
                        );
                      },
                    ),
                    for (var stars = 1; stars <= 5; stars++)
                      ChoiceChip(
                        label: Text('$stars'),
                        selected: _tempFilter.minRating == stars * 20,
                        onSelected: (_) {
                          setState(
                            () => _tempFilter = _tempFilter.copyWith(
                              minRating: stars * 20,
                            ),
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                Text('Image Count', style: context.textTheme.labelLarge),
                const SizedBox(height: AppTheme.spacingSmall),
                Wrap(
                  spacing: AppTheme.spacingSmall,
                  runSpacing: AppTheme.spacingSmall,
                  children: [
                    _buildImageCountChip(0, 50, '< 50'),
                    _buildImageCountChip(50, 200, '50-200'),
                    _buildImageCountChip(200, null, '> 200'),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                Text('Organization', style: context.textTheme.labelLarge),
                const SizedBox(height: AppTheme.spacingSmall),
                FilterChip(
                  label: const Text('Organized only'),
                  selected: _tempOrganizedOnly,
                  onSelected: (selected) {
                    setState(() => _tempOrganizedOnly = selected);
                  },
                ),
                const SizedBox(height: AppTheme.spacingLarge),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(galleryFilterStateProvider.notifier)
                          .update(_tempFilter);
                      ref
                          .read(galleryOrganizedOnlyProvider.notifier)
                          .set(_tempOrganizedOnly);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: context.colors.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingMedium,
                      ),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      ref
                          .read(galleryFilterStateProvider.notifier)
                          .update(_tempFilter);
                      ref
                          .read(galleryOrganizedOnlyProvider.notifier)
                          .set(_tempOrganizedOnly);
                      await ref
                          .read(galleryFilterStateProvider.notifier)
                          .saveAsDefault();
                      await ref
                          .read(galleryOrganizedOnlyProvider.notifier)
                          .saveAsDefault();
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Filter preferences saved as default',
                            ),
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingMedium,
                      ),
                    ),
                    child: const Text('Save as Default'),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageCountChip(int? min, int? max, String label) {
    final isSelected =
        _tempFilter.minImageCount == min && _tempFilter.maxImageCount == max;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _tempFilter = _tempFilter.copyWith(
              minImageCount: min,
              maxImageCount: max,
            );
          } else {
            _tempFilter = _tempFilter.copyWith(
              minImageCount: null,
              maxImageCount: null,
            );
          }
        });
      },
    );
  }
}
