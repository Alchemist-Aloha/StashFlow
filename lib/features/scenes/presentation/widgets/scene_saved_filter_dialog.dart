import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/repositories/graphql_saved_filter_repository.dart';
import '../../../../core/domain/entities/filter_options.dart';
import '../../../../core/presentation/widgets/saved_filter_dialog.dart';
import '../../domain/entities/scene_filter.dart';
import '../../domain/entities/scene_saved_filter_config.dart';
import '../../../../core/utils/l10n_extensions.dart';

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
      activeFilterCount: activeFilterCount(widget.filter.toJson()),
      defaultSortLabel: 'date',
      saveSuccessMessage: context.l10n.saved_item('Scene filter'),
      loadPresets: () => ref
          .read(savedFilterRepositoryProvider)
          .findAll(mode: 'SCENES', fromRaw: SceneSavedFilterConfig.fromRaw),
      savePreset: ({required String name, String? existingId}) {
        return ref
            .read(savedFilterRepositoryProvider)
            .save(
              input: SceneSavedFilterConfig(
                id: existingId,
                name: name,
                searchQuery: widget.searchQuery,
                sort: widget.sort,
                descending: widget.descending,
                filter: widget.filter,
              ).toSaveInput(),
              fromRaw: SceneSavedFilterConfig.fromRaw,
            );
      },
      deletePreset: (id) =>
          ref.read(savedFilterRepositoryProvider).delete(id: id),
      onLoad: widget.onLoad,
    );
  }
}
