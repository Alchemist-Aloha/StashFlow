import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Lazy, repaint-isolated sections for a finite entity detail page.
///
/// The optional header is full-width; content sections use scaled page padding.
/// Visited sections stay mounted until the page leaves the tree, preserving
/// disclosure state, strip positions, and any inline player's lifetime. This is
/// for detail sections, not unbounded media lists.
class DetailPageScrollView extends StatelessWidget {
  const DetailPageScrollView({
    required this.children,
    this.header,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final Widget? header;
  final List<Widget> children;

  /// Insets outside the header and content, including floating chrome clearance.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dimensions.spacingMedium;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: padding,
      children: [
        if (header != null)
          _RetainedDetailSection(
            key: const ValueKey('detail-header'),
            child: header!,
          ),
        SizedBox(height: spacing),
        for (final child in children)
          _RetainedDetailSection(
            key: child.key == null ? null : ValueKey(child.key),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing),
              child: child,
            ),
          ),
        SizedBox(height: spacing),
      ],
    );
  }
}

class _RetainedDetailSection extends StatefulWidget {
  const _RetainedDetailSection({required this.child, super.key});

  final Widget child;

  @override
  State<_RetainedDetailSection> createState() => _RetainedDetailSectionState();
}

class _RetainedDetailSectionState extends State<_RetainedDetailSection>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
