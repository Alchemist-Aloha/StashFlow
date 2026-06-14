import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';

import '../../../setup/presentation/widgets/settings_page_shell.dart';
import '../../../../core/presentation/theme/app_theme.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    void fallbackBack() => context.go('/scenes');

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          fallbackBack();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: canPop
              ? null
              : IconButton(
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  icon: const BackButtonIcon(),
                  onPressed: fallbackBack,
                ),
          title: Text(context.l10n.tools),
        ),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: ListView(
                padding: EdgeInsets.all(context.dimensions.spacingLarge),
                children: [
                  SettingsSectionCard(
                    title: context.l10n.tools,
                    subtitle: context.l10n.tools_section_subtitle,
                    child: const _ToolsActions(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolsActions extends StatelessWidget {
  const _ToolsActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingsActionCard(
          icon: Icons.difference_rounded,
          title: context.l10n.scene_deduplication,
          subtitle: context.l10n.tools_scene_deduplication_subtitle,
          onTap: () => context.push('/tools/scene-deduplication'),
        ),
        SizedBox(height: context.dimensions.spacingMedium),
        SettingsActionCard(
          icon: Icons.sell_rounded,
          title: context.l10n.scene_tagger,
          subtitle: context.l10n.tools_scene_tagger_subtitle,
          onTap: () => context.push('/tools/scene-tagger'),
        ),
      ],
    );
  }
}
