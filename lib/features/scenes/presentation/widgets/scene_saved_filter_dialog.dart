import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/saved_filter_dialog.dart';
import '../../domain/entities/scene_filter.dart';
import '../../domain/entities/scene_saved_filter_config.dart';
import '../providers/scene_list_provider.dart';

class SceneSavedFilterDialog extends ConsumerStatefulWidget {
  const SceneSavedFilterDialog({
    super.key,
    required this.searchQuery,
    required this.sort,
    required this.descending,
    required this.filter,
    required this.onLoad,
  });

  final String searchQuery;
  final String? sort;
  final bool descending;
  final SceneFilter filter;
  final ValueChanged<SceneSavedFilterConfig> onLoad;

  @override
  ConsumerState<SceneSavedFilterDialog> createState() =>
      _SceneSavedFilterDialogState();
}

class _SceneSavedFilterDialogState
    extends ConsumerState<SceneSavedFilterDialog> {
  @override
  Widget build(BuildContext context) {
    return SavedFilterDialog<SceneSavedFilterConfig>(
      searchQuery: widget.searchQuery,
      sort: widget.sort,
      descending: widget.descending,
      activeFilterCount: widget.filter
          .toJson()
          .values
          .where((value) => value != null)
          .length,
      defaultSortLabel: 'date',
      saveSuccessMessage: 'Scene filter saved to server',
      loadPresets: () =>
          ref.read(sceneSavedFilterRepositoryProvider).findAll(),
      savePreset: ({required String name, String? existingId}) {
        return ref
            .read(sceneSavedFilterRepositoryProvider)
            .save(
              SceneSavedFilterConfig.current(
                id: existingId,
                name: name,
                searchQuery: widget.searchQuery,
                sort: widget.sort,
                descending: widget.descending,
                filter: widget.filter,
              ),
            );
      },
      onLoad: widget.onLoad,
    );
  }
}
