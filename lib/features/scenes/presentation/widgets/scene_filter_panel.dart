import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/scene_filter.dart';
import '../providers/scene_list_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';

class SceneFilterPanel extends ConsumerStatefulWidget {
  const SceneFilterPanel({super.key});

  @override
  ConsumerState<SceneFilterPanel> createState() => _SceneFilterPanelState();
}

class _SceneFilterPanelState extends ConsumerState<SceneFilterPanel> {
  late SceneFilter _tempFilter;
  late bool _tempOrganizedOnly;

  @override
  void initState() {
    super.initState();
    _tempFilter = ref.read(sceneFilterStateProvider);
    _tempOrganizedOnly = ref.read(sceneOrganizedOnlyProvider);
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
          child: RepaintBoundary(
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
                        context.l10n.scenes_filter_title,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _tempFilter = SceneFilter.empty();
                            _tempOrganizedOnly = false;
                          });
                        },
                        child: Text(context.l10n.common_reset),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  Text(context.l10n.galleries_min_rating, style: context.textTheme.labelLarge),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      ChoiceChip(
                        label: Text(context.l10n.common_any),
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
                  Text(context.l10n.settings_playback_subtitles, style: context.textTheme.labelLarge),
                  Row(
                    children: [
                      FilterChip(
                        label: Text(context.l10n.scenes_watched),
                        selected: _tempFilter.isWatched == true,
                        onSelected: (selected) {
                          setState(
                            () => _tempFilter = _tempFilter.copyWith(
                              isWatched: selected ? true : null,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: AppTheme.spacingSmall),
                      FilterChip(
                        label: Text(context.l10n.scenes_unwatched),
                        selected: _tempFilter.isWatched == false,
                        onSelected: (selected) {
                          setState(
                            () => _tempFilter = _tempFilter.copyWith(
                              isWatched: selected ? false : null,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Text(context.l10n.common_resolution, style: context.textTheme.labelLarge),
                  const SizedBox(height: AppTheme.spacingSmall),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildResolutionChip('FOUR_K', '4K'),
                        const SizedBox(width: AppTheme.spacingSmall),
                        _buildResolutionChip('FULL_HD', '1080p'),
                        const SizedBox(width: AppTheme.spacingSmall),
                        _buildResolutionChip('STANDARD_HD', '720p'),
                        const SizedBox(width: AppTheme.spacingSmall),
                        _buildResolutionChip('STANDARD', '480p'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Text(context.l10n.common_orientation, style: context.textTheme.labelLarge),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Wrap(
                    spacing: AppTheme.spacingSmall,
                    runSpacing: AppTheme.spacingSmall,
                    children: [
                      _buildOrientationChip('LANDSCAPE', context.l10n.common_landscape),
                      _buildOrientationChip('PORTRAIT', context.l10n.common_portrait),
                      _buildOrientationChip('SQUARE', context.l10n.common_square),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Text(context.l10n.common_date, style: context.textTheme.labelLarge),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Wrap(
                    spacing: AppTheme.spacingSmall,
                    runSpacing: AppTheme.spacingSmall,
                    children: [
                      _buildDurationChip(null, 300, '< 5m'),
                      _buildDurationChip(300, 1200, '5-20m'),
                      _buildDurationChip(1200, null, '> 20m'),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Text(context.l10n.galleries_organization, style: context.textTheme.labelLarge),
                  const SizedBox(height: AppTheme.spacingSmall),
                  FilterChip(
                    label: Text(context.l10n.galleries_organized_only),
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
                            .read(sceneFilterStateProvider.notifier)
                            .update(_tempFilter);
                        ref
                            .read(sceneOrganizedOnlyProvider.notifier)
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
                      child: Text(context.l10n.common_apply_filters),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        ref
                            .read(sceneFilterStateProvider.notifier)
                            .update(_tempFilter);
                        ref
                            .read(sceneOrganizedOnlyProvider.notifier)
                            .set(_tempOrganizedOnly);
                        await ref
                            .read(sceneFilterStateProvider.notifier)
                            .saveAsDefault();
                        await ref
                            .read(sceneOrganizedOnlyProvider.notifier)
                            .saveAsDefault();
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.l10n.galleries_filter_saved),
                            ),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacingMedium,
                        ),
                      ),
                      child: Text(context.l10n.common_save_default),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResolutionChip(String value, String label) {
    final isSelected = _tempFilter.resolutions?.contains(value) ?? false;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _tempFilter = _tempFilter.copyWith(resolutions: [value]);
          } else {
            _tempFilter = _tempFilter.copyWith(resolutions: []);
          }
        });
      },
    );
  }

  Widget _buildOrientationChip(String value, String label) {
    final isSelected = _tempFilter.orientations?.contains(value) ?? false;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          final current = List<String>.from(_tempFilter.orientations ?? []);
          if (selected) {
            current.add(value);
          } else {
            current.remove(value);
          }
          _tempFilter = _tempFilter.copyWith(orientations: current);
        });
      },
    );
  }

  Widget _buildDurationChip(int? min, int? max, String label) {
    final isSelected =
        _tempFilter.minDuration == min && _tempFilter.maxDuration == max;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _tempFilter = _tempFilter.copyWith(
              minDuration: min,
              maxDuration: max,
            );
          } else {
            _tempFilter = _tempFilter.copyWith(
              minDuration: null,
              maxDuration: null,
            );
          }
        });
      },
    );
  }
}
