import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/repositories/graphql_saved_filter_repository.dart';
import '../../../../core/domain/entities/filter_options.dart';
import '../../../../core/presentation/widgets/saved_filter_dialog.dart';
import '../../domain/entities/scene_marker.dart';
import '../../domain/entities/scene_marker_saved_filter_config.dart';
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
      activeFilterCount: activeFilterCount(widget.filter.toJson()),
      defaultSortLabel: 'created_at',
      saveSuccessMessage: context.l10n.saved_item('Marker filter'),
      loadPresets: () => ref
          .read(savedFilterRepositoryProvider)
          .findAll(
            mode: 'SCENE_MARKERS',
            fromRaw: SceneMarkerSavedFilterConfig.fromRaw,
          ),
      savePreset: ({required String name, String? existingId}) {
        return ref
            .read(savedFilterRepositoryProvider)
            .save(
              input: SceneMarkerSavedFilterConfig(
                id: existingId,
                name: name,
                searchQuery: widget.searchQuery,
                sort: widget.sort,
                descending: widget.descending,
                filter: widget.filter,
              ).toSaveInput(),
              fromRaw: SceneMarkerSavedFilterConfig.fromRaw,
            );
      },
      deletePreset: (id) =>
          ref.read(savedFilterRepositoryProvider).delete(id: id),
      onLoad: widget.onLoad,
    );
  }
}
