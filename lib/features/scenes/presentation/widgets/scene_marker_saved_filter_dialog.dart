import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/saved_filter_dialog.dart';
import '../../domain/entities/scene_marker.dart';
import '../../domain/entities/scene_marker_saved_filter_config.dart';
import '../providers/scene_marker_list_provider.dart';
import '../../../../core/utils/l10n_extensions.dart';

class SceneMarkerSavedFilterDialog extends ConsumerStatefulWidget {
  const SceneMarkerSavedFilterDialog({
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
  final SceneMarkerFilter filter;
  final ValueChanged<SceneMarkerSavedFilterConfig> onLoad;

  @override
  ConsumerState<SceneMarkerSavedFilterDialog> createState() =>
      _SceneMarkerSavedFilterDialogState();
}

class _SceneMarkerSavedFilterDialogState
    extends ConsumerState<SceneMarkerSavedFilterDialog> {
  @override
  Widget build(BuildContext context) {
    return SavedFilterDialog<SceneMarkerSavedFilterConfig>(
      searchQuery: widget.searchQuery,
      sort: widget.sort,
      descending: widget.descending,
      activeFilterCount: widget.filter
          .toJson()
          .values
          .where((value) => value != null)
          .length,
      defaultSortLabel: 'created_at',
      saveSuccessMessage: context.l10n.saved_item('Marker filter'),
      loadPresets: () =>
          ref.read(sceneMarkerSavedFilterRepositoryProvider).findAll(),
      savePreset: ({required String name, String? existingId}) {
        return ref
            .read(sceneMarkerSavedFilterRepositoryProvider)
            .save(
              SceneMarkerSavedFilterConfig.current(
                id: existingId,
                name: name,
                searchQuery: widget.searchQuery,
                sort: widget.sort,
                descending: widget.descending,
                filter: widget.filter,
              ),
            );
      },
      deletePreset: (id) =>
          ref.read(sceneMarkerSavedFilterRepositoryProvider).delete(id),
      onLoad: widget.onLoad,
    );
  }
}
