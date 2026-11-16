import 'package:material_ui/material_ui.dart';

import '../../../../core/presentation/widgets/one_time_tip_dialog.dart';
import '../../../../core/utils/l10n_extensions.dart';

/// Shows the one-time fullscreen image swipe direction choice.
///
/// Resolves to `true` for vertical, `false` for horizontal, or `null` when
/// dismissed.
Future<bool?> showImageSwipeDirectionDialog(BuildContext context) =>
    showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = context.l10n;
        return OneTimeTipDialog(
          title: l10n.onboarding_image_title,
          hints: [
            (
              icon: Icons.photo_library_outlined,
              text: l10n.settings_interface_swipe_direction_desc,
            ),
          ],
          choices: [
            TipChoice(
              key: const Key('image-swipe-vertical'),
              label: l10n.settings_interface_swipe_vertical,
              visual: const TipChoiceIcon(Icons.swap_vert_rounded),
              onTap: () => Navigator.of(context).pop(true),
            ),
            TipChoice(
              key: const Key('image-swipe-horizontal'),
              label: l10n.settings_interface_swipe_horizontal,
              visual: const TipChoiceIcon(Icons.swap_horiz_rounded),
              onTap: () => Navigator.of(context).pop(false),
            ),
          ],
          footnote: l10n.scene_view_mode_prompt_settings_hint,
        );
      },
    );
