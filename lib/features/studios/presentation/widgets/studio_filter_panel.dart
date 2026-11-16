import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/l10n_extensions.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/studio_filter.dart';
import '../../../../core/domain/entities/criterion.dart';
import '../providers/studio_list_provider.dart';
import '../../../../core/presentation/widgets/filter_bottom_sheet_scaffold.dart';
import '../../../../core/presentation/widgets/filter_widgets.dart';
import '../../domain/entities/studio.dart';
import '../../../tags/domain/entities/tag.dart';

class StudioFilterPanel extends ConsumerStatefulWidget {
  const StudioFilterPanel({super.key});

  @override
  ConsumerState<StudioFilterPanel> createState() => _StudioFilterPanelState();
}

class _StudioFilterPanelState extends ConsumerState<StudioFilterPanel> {
  late StudioFilter _tempFilter;

  @override
  void initState() {
    super.initState();
    _tempFilter = ref.read(studioFilterStateProvider);
  }

  @override
  Widget build(BuildContext context) {
    return FilterBottomSheetScaffold(
      title: context.l10n.studios_filter_title,
      onReset: () {
        setState(() {
          _tempFilter = StudioFilter.empty();
        });
      },
      body: Column(
        children: [
          _buildGeneralSection(),
          _buildMetadataSection(),
          _buildLibrarySection(),
          _buildSystemSection(),
        ],
      ),
      onApply: () =>
          ref.read(studioFilterStateProvider.notifier).update(_tempFilter),
      onSaveDefault: () async {
        ref.read(studioFilterStateProvider.notifier).update(_tempFilter);
        await ref.read(studioFilterStateProvider.notifier).saveAsDefault();
      },
      saveDefaultSuccessMessage: context.l10n.studios_filter_saved,
    );
  }

  Widget _buildGeneralSection() {
    return FilterSection(
      title: context.l10n.filter_group_general,
      initiallyExpanded: true,
      children: [
        BooleanCriterionInput(
          label: 'Favorite',
          value: _tempFilter.favorite,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(favorite: val)),
        ),
        RatingCriterionInput(
          criterion: _tempFilter.rating100,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(rating100: value),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataSection() {
    return FilterSection(
      title: context.l10n.filter_group_metadata,
      children: [
        StringCriterionInput(
          label: context.l10n.studios_field_name,
          value: _tempFilter.name,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(name: val)),
        ),
        StringCriterionInput(
          label: context.l10n.studios_field_details,
          value: _tempFilter.details,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(details: val)),
        ),
        StringCriterionInput(
          label: context.l10n.studios_field_aliases,
          value: _tempFilter.aliases,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(aliases: val)),
        ),
        StringCriterionInput(
          label: context.l10n.studios_field_url,
          value: _tempFilter.url,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(url: val)),
        ),
      ],
    );
  }

  Widget _buildLibrarySection() {
    return FilterSection(
      title: context.l10n.filter_group_library,
      children: [
        BooleanCriterionInput(
          label: context.l10n.common_organized,
          value: _tempFilter.organized,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(organized: value),
          ),
        ),
        EntityCriterionInput<Studio>(
          label: 'Parent Studios',
          providerType: 'studio',
          criterion: _tempFilter.parentStudios,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              parentStudios: val as HierarchicalMultiCriterion?,
            ),
          ),
          isHierarchical: true,
        ),
        EntityCriterionInput<Tag>(
          label: 'Tags',
          providerType: 'tag',
          criterion: _tempFilter.tags,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              tags: val as HierarchicalMultiCriterion?,
            ),
          ),
          isHierarchical: true,
        ),
        IntCriterionInput(
          label: context.l10n.studios_field_tag_count,
          value: _tempFilter.tagCount,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(tagCount: val)),
        ),
      ],
    );
  }

  Widget _buildSystemSection() {
    return FilterSection(
      title: context.l10n.filter_group_system,
      children: [
        MissingFieldCriterionInput(
          value: _tempFilter.isMissing,
          fields: const [
            'image',
            'stash_id',
            'details',
            'url',
            'aliases',
            'tags',
            'rating',
          ],
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(isMissing: value),
          ),
        ),
        StashIdCriterionInput(
          value: _tempFilter.stashIdEndpoint,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(stashIdEndpoint: value),
          ),
        ),
        CustomFieldsCriterionInput(
          value: _tempFilter.customFields,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(customFields: value),
          ),
        ),
        BooleanCriterionInput(
          label: 'Ignore Auto Tag',
          value: _tempFilter.ignoreAutoTag,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(ignoreAutoTag: val),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.studios_field_scene_count,
          value: _tempFilter.sceneCount,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(sceneCount: val),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.studios_field_image_count,
          value: _tempFilter.imageCount,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(imageCount: val),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.studios_field_gallery_count,
          value: _tempFilter.galleryCount,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(galleryCount: val),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.studios_field_sub_studio_count,
          value: _tempFilter.childCount,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(childCount: val),
          ),
        ),
        DateCriterionInput(
          label: context.l10n.studios_field_created_at,
          value: _tempFilter.createdAt,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(createdAt: val),
          ),
        ),
        DateCriterionInput(
          label: context.l10n.studios_field_updated_at,
          value: _tempFilter.updatedAt,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(updatedAt: val),
          ),
        ),
      ],
    );
  }
}
