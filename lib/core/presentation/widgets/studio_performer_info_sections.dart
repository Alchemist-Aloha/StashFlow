import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/graphql/media_headers_provider.dart';
import '../theme/app_theme.dart';
import '../../utils/l10n_extensions.dart';
import 'section_panel.dart';
import 'stash_image.dart';

/// Scene-style studio and performer sections for entity details sheets.
class StudioPerformerInfoSections extends ConsumerWidget {
  const StudioPerformerInfoSections({
    required this.studioId,
    required this.studioName,
    required this.performerIds,
    required this.performerNames,
    required this.performerImagePaths,
    super.key,
  });

  final String? studioId;
  final String? studioName;
  final List<String> performerIds;
  final List<String> performerNames;
  final List<String?> performerImagePaths;

  /// Whether at least one studio or performer section can be shown.
  static bool isVisible({
    required String? studioName,
    required List<String> performerNames,
  }) => (studioName ?? '').trim().isNotEmpty || performerNames.isNotEmpty;

  void _closeAndNavigate(BuildContext context, String route) {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    unawaited(router.push(route));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dims = context.dimensions;
    final mediaHeaders = ref.watch(mediaHeadersProvider);
    final hasStudio = (studioName ?? '').trim().isNotEmpty;

    return Column(
      children: [
        if (hasStudio)
          _InfoSectionCard(
            title: context.l10n.studios_title,
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(studioName!),
              subtitle: studioId != null
                  ? Text(context.l10n.scene_studio_id(studioId!))
                  : null,
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: studioId?.trim().isNotEmpty == true
                  ? () =>
                        _closeAndNavigate(context, '/studios/studio/$studioId')
                  : null,
            ),
          ),
        if (hasStudio && performerNames.isNotEmpty)
          SizedBox(height: dims.spacingMedium),
        if (performerNames.isNotEmpty)
          RepaintBoundary(
            child: _InfoSectionCard(
              title: context.l10n.performers_title,
              child: Column(
                children: List.generate(performerNames.length, (index) {
                  final performerId = index < performerIds.length
                      ? performerIds[index]
                      : null;
                  final performerImagePath = index < performerImagePaths.length
                      ? performerImagePaths[index]
                      : null;
                  final hasImage =
                      performerImagePath != null &&
                      performerImagePath.trim().isNotEmpty &&
                      !performerImagePath.contains('default=true');
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    minLeadingWidth: 36 * dims.fontSizeFactor,
                    leading: hasImage
                        ? CircleAvatar(
                            radius: 14 * dims.fontSizeFactor,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            foregroundImage: StashImage.provider(
                              ref,
                              performerImagePath,
                              headers: mediaHeaders,
                            ),
                            child: Icon(
                              Icons.person,
                              size: 14 * dims.fontSizeFactor,
                            ),
                          )
                        : CircleAvatar(
                            radius: 14 * dims.fontSizeFactor,
                            child: Icon(
                              Icons.person,
                              size: 14 * dims.fontSizeFactor,
                            ),
                          ),
                    title: Text(
                      performerNames[index].isNotEmpty
                          ? performerNames[index]
                          : context.l10n.common_unknown,
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: performerId?.trim().isNotEmpty == true
                        ? () => _closeAndNavigate(
                            context,
                            '/performers/performer/$performerId',
                          )
                        : null,
                  );
                }),
              ),
            ),
          ),
      ],
    );
  }
}

class _InfoSectionCard extends StatelessWidget {
  const _InfoSectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      SectionPanel(title: title, child: child);
}
