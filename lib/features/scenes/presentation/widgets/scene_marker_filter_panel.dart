import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/criterion.dart';
import '../../../../core/presentation/widgets/filter_bottom_sheet_scaffold.dart';
import '../../../../core/presentation/widgets/filter_widgets.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../performers/domain/entities/performer.dart';
import '../../../tags/domain/entities/tag.dart';
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_marker.dart';
import '../providers/scene_marker_list_provider.dart';
import 'entity_picker.dart';

class SceneMarkerFilterPanel extends ConsumerStatefulWidget {
  const SceneMarkerFilterPanel({super.key});

  @override
  ConsumerState<SceneMarkerFilterPanel> createState() =>
      _SceneMarkerFilterPanelState();
}

class _SceneMarkerFilterPanelState
    extends ConsumerState<SceneMarkerFilterPanel> {
  late SceneMarkerFilter _tempFilter;

  @override
  void initState() {
    super.initState();
    _tempFilter = ref.read(sceneMarkerFilterStateProvider);
  }

  @override
  Widget build(BuildContext context) {
    return FilterBottomSheetScaffold(
      title: context.l10n.filter_markers_title,
      onReset: () {
        setState(() {
          _tempFilter = const SceneMarkerFilter();
        });
      },
      body: Column(
        children: [
          _buildMarkerSection(),
          _buildSceneSection(),
          _buildDatesSection(),
        ],
      ),
      onApply: () =>
          ref.read(sceneMarkerFilterStateProvider.notifier).update(_tempFilter),
      onSaveDefault: () async {
        ref.read(sceneMarkerFilterStateProvider.notifier).update(_tempFilter);
        await ref.read(sceneMarkerFilterStateProvider.notifier).saveAsDefault();
      },
      saveDefaultSuccessMessage: context.l10n.scenes_filter_saved,
    );
  }

  Widget _buildMarkerSection() {
    return FilterSection(
      title: context.l10n.marker_title,
      initiallyExpanded: true,
      children: [
        _buildEntityFilter<Tag>(
          context.l10n.tags_title,
          'tag',
          _tempFilter.tags,
          (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              tags: value as HierarchicalMultiCriterion?,
              clearTags: value == null,
            ),
          ),
          true,
        ),
        IntCriterionInput(
          label: context.l10n.duration_title,
          value: _tempFilter.duration,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              duration: value,
              clearDuration: value == null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSceneSection() {
    return FilterSection(
      title: context.l10n.scene_title,
      children: [
        _buildEntityFilter<Scene>(
          context.l10n.scenes_title,
          'scene',
          _tempFilter.scenes,
          (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              scenes: value as MultiCriterion?,
              clearScenes: value == null,
            ),
          ),
          false,
        ),
        _buildEntityFilter<Tag>(
          'Scene Tags',
          'tag',
          _tempFilter.sceneTags,
          (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              sceneTags: value as HierarchicalMultiCriterion?,
              clearSceneTags: value == null,
            ),
          ),
          true,
        ),
        _buildEntityFilter<Performer>(
          'Performers',
          'performer',
          _tempFilter.performers,
          (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              performers: value as MultiCriterion?,
              clearPerformers: value == null,
            ),
          ),
          false,
        ),
      ],
    );
  }

  Widget _buildDatesSection() {
    return FilterSection(
      title: context.l10n.dates_title,
      children: [
        DateCriterionInput(
          label: context.l10n.created_at_title,
          value: _tempFilter.createdAt,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              createdAt: value,
              clearCreatedAt: value == null,
            ),
          ),
        ),
        DateCriterionInput(
          label: context.l10n.updated_at_title,
          value: _tempFilter.updatedAt,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              updatedAt: value,
              clearUpdatedAt: value == null,
            ),
          ),
        ),
        DateCriterionInput(
          label: context.l10n.scene_date_title,
          value: _tempFilter.sceneDate,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              sceneDate: value,
              clearSceneDate: value == null,
            ),
          ),
        ),
        DateCriterionInput(
          label: context.l10n.scene_created_at_title,
          value: _tempFilter.sceneCreatedAt,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              sceneCreatedAt: value,
              clearSceneCreatedAt: value == null,
            ),
          ),
        ),
        DateCriterionInput(
          label: context.l10n.scene_updated_at_title,
          value: _tempFilter.sceneUpdatedAt,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              sceneUpdatedAt: value,
              clearSceneUpdatedAt: value == null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEntityFilter<T>(
    String label,
    String providerType,
    dynamic criterion,
    ValueChanged<dynamic> onChanged,
    bool isHierarchical,
  ) {
    final List<String> selectedIds = criterion?.value ?? [];
    final modifier = criterion?.modifier ?? CriterionModifier.includes;

    return SelectionCriterionInput(
      label: label,
      selectedIds: selectedIds,
      modifier: modifier,
      onModifierChanged: (next) {
        onChanged(
          _buildEntityCriterion(
            ids: selectedIds,
            modifier: next,
            isHierarchical: isHierarchical,
          ),
        );
      },
      onAddPressed: () async {
        final result = await showDialog<List<T>>(
          context: context,
          builder: (context) => EntityPicker<T>(
            title: context.l10n.common_select(label),
            providerType: providerType,
            multiSelect: true,
            initialSelection: selectedIds,
          ),
        );
        if (result == null) return;

        final ids = result.map((entity) => _extractEntityId(entity)).toList();
        if (ids.isEmpty) {
          onChanged(null);
          return;
        }

        onChanged(
          _buildEntityCriterion(
            ids: ids,
            modifier: modifier,
            isHierarchical: isHierarchical,
          ),
        );
      },
      onRemoveId: (id) {
        final newList = List<String>.from(selectedIds)..remove(id);
        if (newList.isEmpty) {
          onChanged(null);
          return;
        }

        onChanged(
          _buildEntityCriterion(
            ids: newList,
            modifier: modifier,
            isHierarchical: isHierarchical,
          ),
        );
      },
    );
  }

  dynamic _buildEntityCriterion({
    required List<String> ids,
    required CriterionModifier modifier,
    required bool isHierarchical,
  }) {
    if (isHierarchical) {
      return HierarchicalMultiCriterion(value: ids, modifier: modifier);
    }
    return MultiCriterion(value: ids, modifier: modifier);
  }

  String _extractEntityId(Object? entity) {
    if (entity is Tag) return entity.id;
    if (entity is Performer) return entity.id;
    if (entity is Scene) return entity.id;
    throw StateError(
      'Unsupported scene marker filter entity: ${entity.runtimeType}',
    );
  }
}
