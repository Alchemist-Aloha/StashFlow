import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/providers/app_language_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';

/// Shows the app language bottom sheet; completes when it closes.
Future<void> showAppLanguagePicker(BuildContext context, WidgetRef ref) {
  final colorScheme = Theme.of(context).colorScheme;
  final currentLanguageKey = ref
      .read(sharedPreferencesProvider)
      .getString(appLanguagePreferenceKey);
  final languageEntries = supportedLanguages.entries.toList(growable: false);

  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppTheme.radiusExtraLarge),
      ),
    ),
    builder: (context) {
      final textTheme = context.textTheme;
      final fontSizeFactor = context.dimensions.fontSizeFactor;

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: context.dimensions.spacingMedium),
            Container(
              width: 32 * context.dimensions.fontSizeFactor,
              height: 4 * context.dimensions.fontSizeFactor,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(
                  2 * context.dimensions.fontSizeFactor,
                ),
              ),
            ),
            SizedBox(height: context.dimensions.spacingMedium),
            Flexible(
              child: ListView.builder(
                itemCount: languageEntries.length,
                itemBuilder: (context, index) {
                  final entry = languageEntries[index];
                  final isSelected = entry.key == currentLanguageKey;
                  return ListTile(
                    leading: Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: isSelected ? colorScheme.primary : null,
                      size: 24 * fontSizeFactor,
                    ),
                    title: Text(
                      entry.key == null
                          ? context.l10n.settings_appearance_theme_system
                          : entry.value,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : null,
                      ),
                    ),
                    onTap: () async {
                      await ref
                          .read(appLanguageProvider.notifier)
                          .setLanguage(entry.key);
                      if (context.mounted) Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
