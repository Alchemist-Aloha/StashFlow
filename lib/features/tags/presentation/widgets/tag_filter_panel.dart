import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/filter_bottom_sheet_scaffold.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/presentation/widgets/filter_widgets.dart';
import '../providers/tag_list_provider.dart';

class TagFilterPanel extends ConsumerStatefulWidget {
  const TagFilterPanel({super.key});

  @override
  ConsumerState<TagFilterPanel> createState() => _TagFilterPanelState();
}

class _TagFilterPanelState extends ConsumerState<TagFilterPanel> {
  late bool _tempFavoritesOnly;

  @override
  void initState() {
    super.initState();
    _tempFavoritesOnly = ref.read(tagFavoritesOnlyProvider);
  }

  @override
  Widget build(BuildContext context) {
    return FilterBottomSheetScaffold(
      title: context.l10n.tags_filter_title,
      onReset: () {
        setState(() {
          _tempFavoritesOnly = false;
        });
      },
      body: Column(children: [_buildGeneralSection()]),
      onApply: () => ref
          .read(tagListProvider.notifier)
          .setFavoritesOnly(_tempFavoritesOnly),
      onSaveDefault: () async {
        ref.read(tagListProvider.notifier).setFavoritesOnly(_tempFavoritesOnly);
        await ref.read(tagFavoritesOnlyProvider.notifier).saveAsDefault();
      },
      saveDefaultSuccessMessage: context.l10n.tags_filter_saved,
    );
  }

  Widget _buildGeneralSection() {
    return FilterSection(
      title: context.l10n.filter_group_general,
      initiallyExpanded: true,
      children: [
        SwitchListTile(
          title: Text(context.l10n.common_favorites_only),
          contentPadding: EdgeInsets.zero,
          value: _tempFavoritesOnly,
          onChanged: (value) {
            setState(() {
              _tempFavoritesOnly = value;
            });
          },
        ),
      ],
    );
  }
}
