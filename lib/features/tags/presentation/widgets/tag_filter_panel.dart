import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/theme/app_theme.dart';
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
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      top: false,
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusExtraLarge),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(context.dimensions.spacingMedium),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.tags_filter_title,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _tempFavoritesOnly = false;
                        });
                      },
                      child: Text(context.l10n.common_reset),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: bottomInset +
                        safeBottom +
                        context.dimensions.spacingLarge,
                  ),
                  child: Column(
                    children: [
                      _buildGeneralSection(),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: EdgeInsets.all(context.dimensions.spacingMedium),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ref
                              .read(tagListProvider.notifier)
                              .setFavoritesOnly(_tempFavoritesOnly);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.primary,
                          foregroundColor: context.colors.onPrimary,
                          padding: EdgeInsets.symmetric(
                            vertical: context.dimensions.spacingMedium,
                          ),
                        ),
                        child: Text(context.l10n.common_apply_filters),
                      ),
                    ),
                    SizedBox(height: context.dimensions.spacingSmall),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () async {
                          ref
                              .read(tagListProvider.notifier)
                              .setFavoritesOnly(_tempFavoritesOnly);
                          await ref
                              .read(tagFavoritesOnlyProvider.notifier)
                              .saveAsDefault();
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  context.l10n.tags_filter_saved,
                                ),
                              ),
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: context.dimensions.spacingMedium,
                          ),
                        ),
                        child: Text(context.l10n.common_save_default),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralSection() {
    return FilterSection(
      title: context.l10n.filter_group_general,
      initiallyExpanded: true,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.l10n.common_favorites_only),
            Switch(
              value: _tempFavoritesOnly,
              onChanged: (value) {
                setState(() {
                  _tempFavoritesOnly = value;
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}
