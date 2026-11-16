import 'package:material_ui/material_ui.dart';

import '../../../../core/presentation/widgets/stash_image.dart';

/// A group's box-art cover, or the group icon when Stash only has its
/// placeholder (`default=true`) image.
class GroupCover extends StatelessWidget {
  const GroupCover({
    required this.imagePath,
    required this.width,
    required this.height,
    this.memCacheWidth,
    super.key,
  });

  final String? imagePath;
  final double width;
  final double height;
  final int? memCacheWidth;

  /// Whether [path] is a real cover rather than Stash's placeholder.
  static bool hasCover(String? path) =>
      path != null && path.isNotEmpty && !path.contains('default=true');

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      height: height,
      child: hasCover(imagePath)
          ? StashImage(
              imageUrl: imagePath!,
              width: width,
              height: height,
              fit: BoxFit.contain,
              memCacheWidth: memCacheWidth,
            )
          : ColoredBox(
              color: colors.surfaceContainerHighest,
              child: Icon(
                Icons.group_work,
                size: height / 2.5,
                color: colors.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
    );
  }
}
