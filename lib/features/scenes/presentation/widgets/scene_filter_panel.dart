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

  @override
  void initState() {
    super.initState();
    _tempFilter = ref.read(sceneFilterStateProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLarge)),
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
                style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  setState(() => _tempFilter = SceneFilter.empty());
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
              setState(() => _tempFilter = _tempFilter.copyWith(minRating: value.toInt()));
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
                  setState(() => _tempFilter = _tempFilter.copyWith(isWatched: selected ? true : null));
                },
              ),
              const SizedBox(width: AppTheme.spacingSmall),
              FilterChip(
                label: const Text('Unwatched'),
                selected: _tempFilter.isWatched == false,
                onSelected: (selected) {
                  setState(() => _tempFilter = _tempFilter.copyWith(isWatched: selected ? false : null));
                },
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref.read(sceneFilterStateProvider.notifier).update(_tempFilter);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
              ),
              child: const Text('Apply Filters'),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
        ],
      ),
    );
  }
}
