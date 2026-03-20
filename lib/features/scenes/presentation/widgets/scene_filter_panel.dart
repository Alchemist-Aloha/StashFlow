import 'package:flutter/material.dart';
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
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusExtraLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Scenes',
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
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Text('Minimum Rating', style: context.textTheme.labelLarge),
          Slider(
            value: (_tempFilter.minRating ?? 0).toDouble(),
            min: 0,
            max: 100,
            divisions: 5,
            label: '${(_tempFilter.minRating ?? 0) ~/ 20} Stars',
            onChanged: (value) {
              setState(
                () => _tempFilter = _tempFilter.copyWith(
                  minRating: value.toInt(),
                ),
              );
            },
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          Text('Watched Status', style: context.textTheme.labelLarge),
          Row(
            children: [
              FilterChip(
                label: const Text('Watched'),
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
                label: const Text('Unwatched'),
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
          Text('Resolution', style: context.textTheme.labelLarge),
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
          Text('Orientation', style: context.textTheme.labelLarge),
          const SizedBox(height: AppTheme.spacingSmall),
          Row(
            children: [
              _buildOrientationChip('LANDSCAPE', 'Landscape'),
              const SizedBox(width: AppTheme.spacingSmall),
              _buildOrientationChip('PORTRAIT', 'Portrait'),
              const SizedBox(width: AppTheme.spacingSmall),
              _buildOrientationChip('SQUARE', 'Square'),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          Text('Duration', style: context.textTheme.labelLarge),
          const SizedBox(height: AppTheme.spacingSmall),
          Row(
            children: [
              _buildDurationChip(null, 300, '< 5m'),
              const SizedBox(width: AppTheme.spacingSmall),
              _buildDurationChip(300, 1200, '5-20m'),
              const SizedBox(width: AppTheme.spacingSmall),
              _buildDurationChip(1200, null, '> 20m'),
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
                ref.read(sceneFilterStateProvider.notifier).update(_tempFilter);
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
              child: const Text('Apply Filters'),
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                ref.read(sceneFilterStateProvider.notifier).update(_tempFilter);
                ref
                    .read(sceneOrganizedOnlyProvider.notifier)
                    .set(_tempOrganizedOnly);
                await ref.read(sceneFilterStateProvider.notifier).saveAsDefault();
                await ref
                    .read(sceneOrganizedOnlyProvider.notifier)
                    .saveAsDefault();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Filter preferences saved as default'),
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
            _tempFilter = _tempFilter.copyWith(minDuration: min, maxDuration: max);
          } else {
            _tempFilter =
                _tempFilter.copyWith(minDuration: null, maxDuration: null);
          }
        });
      },
    );
  }
}
