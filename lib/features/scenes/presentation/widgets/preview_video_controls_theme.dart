import 'package:material_ui/material_ui.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../core/presentation/theme/app_theme.dart';

/// Shared inset recipe for scene-info and tagger preview controls.
///
/// Only controls layout is shared; each preview retains ownership of its player.
class PreviewVideoControlsTheme extends StatelessWidget {
  const PreviewVideoControlsTheme({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dims = context.dimensions;
    final seekMargin = EdgeInsets.fromLTRB(
      dims.spacingSmall * 1.5,
      0,
      dims.spacingSmall * 1.5,
      dims.spacingSmall,
    );
    final mobileControls = MaterialVideoControlsThemeData(
      bottomButtonBarMargin: seekMargin.copyWith(right: dims.spacingSmall / 2),
      seekBarMargin: seekMargin,
    );
    final desktopControls = MaterialDesktopVideoControlsThemeData(
      bottomButtonBarMargin: seekMargin,
      seekBarMargin: seekMargin,
    );

    return MaterialVideoControlsTheme(
      normal: mobileControls,
      fullscreen: mobileControls,
      child: MaterialDesktopVideoControlsTheme(
        normal: desktopControls,
        fullscreen: desktopControls,
        child: child,
      ),
    );
  }
}
