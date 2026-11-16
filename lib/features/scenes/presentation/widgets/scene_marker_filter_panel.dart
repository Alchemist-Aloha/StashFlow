import 'package:material_ui/material_ui.dart';
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
        EntityCriterionInput<Tag>(
          label: context.l10n.tags_title,
          providerType: 'tag',
          criterion: _tempFilter.tags,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              tags: value as HierarchicalMultiCriterion?,
              clearTags: value == null,
            ),
          ),
          isHierarchical: true,
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
        EntityCriterionInput<Scene>(
          label: context.l10n.scenes_title,
          providerType: 'scene',
          criterion: _tempFilter.scenes,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              scenes: value as MultiCriterion?,
              clearScenes: value == null,
            ),
          ),
        ),
        EntityCriterionInput<Tag>(
          label: 'Scene Tags',
          providerType: 'tag',
          criterion: _tempFilter.sceneTags,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              sceneTags: value as HierarchicalMultiCriterion?,
              clearSceneTags: value == null,
            ),
          ),
          isHierarchical: true,
        ),
        EntityCriterionInput<Performer>(
          label: 'Performers',
          providerType: 'performer',
          criterion: _tempFilter.performers,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              performers: value as MultiCriterion?,
              clearPerformers: value == null,
            ),
          ),
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
}
