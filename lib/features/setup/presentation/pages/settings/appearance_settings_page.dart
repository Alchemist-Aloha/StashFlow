import 'dart:async';

import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import 'package:stash_app_flutter/core/presentation/theme/theme_mode_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/theme_color_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/true_black_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/font_family_provider.dart';
import 'package:stash_app_flutter/core/presentation/providers/layout_settings_provider.dart';
import 'package:stash_app_flutter/core/presentation/providers/app_language_provider.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import '../../widgets/settings_page_shell.dart';
import '../../widgets/theme_color_picker_dialog.dart';

class AppearanceSettingsPage extends ConsumerStatefulWidget {
  const AppearanceSettingsPage({super.key});

  @override
  ConsumerState<AppearanceSettingsPage> createState() =>
      _AppearanceSettingsPageState();
}

class _AppearanceSettingsPageState
    extends ConsumerState<AppearanceSettingsPage> {
  static const _presetColors = [
    Color(0xFF0F766E), // Teal
    Color(0xFF2196F3), // Blue
    Color(0xFF9C27B0), // Purple
    Color(0xFFFF9800), // Orange
    Color(0xFFF44336), // Red
    Color(0xFF4CAF50), // Green
  ];

  Color _seedColor = const Color(0xFF0F766E);
  ThemeMode _themeMode = ThemeMode.system;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final themeMode = ref.read(appThemeModeProvider);
    final seedColor = ref.read(appThemeColorProvider);

    _themeMode = themeMode;
    _seedColor = seedColor;

    setState(() => _loading = false);
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    await ref.read(appThemeModeProvider.notifier).setThemeMode(mode);
  }

  Future<void> _saveThemeColor(Color color) async {
    setState(() => _seedColor = color);
    await ref.read(appThemeColorProvider.notifier).setThemeColor(color);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appLanguageProvider);
    final currentLanguageKey = ref
        .read(sharedPreferencesProvider)
        .getString(appLanguagePreferenceKey);
    final l10n = AppLocalizations.of(context)!;

    return SettingsPageShell(
      title: l10n.settings_appearance_title,
      child: _loading
          ? const SettingsLoadingState()
          : SettingsPageBody(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SettingsSectionCard(
                    title: l10n.settings_interface_language,
                    subtitle: l10n.settings_interface_language_subtitle,
                    child: SettingsActionCard(
                      icon: Icons.translate_rounded,
                      title: l10n.settings_interface_app_language,
                      subtitle: currentLanguageKey == null
                          ? l10n.settings_appearance_theme_system
                          : supportedLanguages[currentLanguageKey] ??
                                l10n.settings_appearance_theme_system,
                      onTap: () => _showLanguagePicker(context, ref),
                    ),
                  ),
                  SizedBox(height: context.dimensions.spacingLarge),
                  SettingsSectionCard(
                    title: l10n.settings_appearance_theme_mode,
                    subtitle: l10n.settings_appearance_theme_mode_subtitle,
                    child: SettingsPanelGroup(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusExtraLarge,
                            ),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: SegmentedButton<ThemeMode>(
                            showSelectedIcon: false,
                            segments: [
                              ButtonSegment<ThemeMode>(
                                value: ThemeMode.system,
                                icon: Icon(
                                  Icons.brightness_auto_outlined,
                                  size: 24 * context.dimensions.fontSizeFactor,
                                ),
                                label: Text(
                                  l10n.settings_appearance_theme_system,
                                ),
                              ),
                              ButtonSegment<ThemeMode>(
                                value: ThemeMode.light,
                                icon: Icon(
                                  Icons.light_mode_outlined,
                                  size: 24 * context.dimensions.fontSizeFactor,
                                ),
                                label: Text(
                                  l10n.settings_appearance_theme_light,
                                ),
                              ),
                              ButtonSegment<ThemeMode>(
                                value: ThemeMode.dark,
                                icon: Icon(
                                  Icons.dark_mode_outlined,
                                  size: 24 * context.dimensions.fontSizeFactor,
                                ),
                                label: Text(
                                  l10n.settings_appearance_theme_dark,
                                ),
                              ),
                            ],
                            selected: {_themeMode},
                            onSelectionChanged: (selection) {
                              unawaited(_saveThemeMode(selection.first));
                            },
                          ),
                        ),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.settings_appearance_true_black),
                          subtitle: Text(
                            l10n.settings_appearance_true_black_subtitle,
                          ),
                          value: ref.watch(trueBlackEnabledProvider),
                          onChanged: (value) {
                            unawaited(
                              ref
                                  .read(trueBlackEnabledProvider.notifier)
                                  .set(value),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SettingsSectionCard(
                    title: l10n.settings_appearance_primary_color,
                    subtitle: l10n.settings_appearance_primary_color_subtitle,
                    child: _buildColorSelector(),
                  ),
                  SettingsSectionCard(
                    title: l10n.settings_appearance_font_family,
                    subtitle: l10n.settings_appearance_font_family_subtitle,
                    child: DropdownButtonFormField<AppFontFamily>(
                      key: ValueKey(ref.watch(appFontFamilyProvider)),
                      initialValue: ref.watch(appFontFamilyProvider),
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: l10n.settings_appearance_font_family,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: AppFontFamily.system,
                          child: Text(l10n.settings_appearance_font_system),
                        ),
                        DropdownMenuItem(
                          value: AppFontFamily.serif,
                          child: Text(l10n.settings_appearance_font_serif),
                        ),
                        DropdownMenuItem(
                          value: AppFontFamily.monospace,
                          child: Text(l10n.settings_appearance_font_monospace),
                        ),
                        DropdownMenuItem(
                          value: AppFontFamily.manrope,
                          child: Text(
                            l10n.settings_appearance_font_manrope,
                            style: const TextStyle(fontFamily: 'Manrope'),
                          ),
                        ),
                        DropdownMenuItem(
                          value: AppFontFamily.outfit,
                          child: Text(
                            l10n.settings_appearance_font_outfit,
                            style: const TextStyle(fontFamily: 'Outfit'),
                          ),
                        ),
                        DropdownMenuItem(
                          value: AppFontFamily.spaceGrotesk,
                          child: Text(
                            l10n.settings_appearance_font_space_grotesk,
                            style: const TextStyle(fontFamily: 'SpaceGrotesk'),
                          ),
                        ),
                        DropdownMenuItem(
                          value: AppFontFamily.inter,
                          child: Text(
                            l10n.settings_appearance_font_inter,
                            style: const TextStyle(fontFamily: 'Inter'),
                          ),
                        ),
                        DropdownMenuItem(
                          value: AppFontFamily.lora,
                          child: Text(
                            l10n.settings_appearance_font_lora,
                            style: const TextStyle(fontFamily: 'Lora'),
                          ),
                        ),
                        DropdownMenuItem(
                          value: AppFontFamily.jetBrainsMono,
                          child: Text(
                            l10n.settings_appearance_font_jetbrains_mono,
                            style: const TextStyle(fontFamily: 'JetBrainsMono'),
                          ),
                        ),
                      ],
                      onChanged: (family) {
                        if (family != null) {
                          unawaited(
                            ref
                                .read(appFontFamilyProvider.notifier)
                                .setFontFamily(family),
                          );
                        }
                      },
                    ),
                  ),
                  SettingsSectionCard(
                    title: l10n.settings_appearance_font_size,
                    subtitle: l10n.settings_appearance_font_size_subtitle,
                    child: _buildGlobalScaleSlider(l10n),
                  ),
                ],
              ),
            ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentLanguageKey = ref
        .read(sharedPreferencesProvider)
        .getString(appLanguagePreferenceKey);
    final languageEntries = supportedLanguages.entries.toList(growable: false);

    unawaited(
      showModalBottomSheet<void>(
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
      ),
    );
  }

  Widget _buildGlobalScaleSlider(AppLocalizations l10n) {
    final value = ref.watch(appGlobalScaleProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(value * 100).toInt()}%',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: value == 1.0
                  ? null
                  : () => ref.read(appGlobalScaleProvider.notifier).set(1.0),
              icon: const Icon(Icons.restart_alt, size: 18),
              label: Text(l10n.common_reset),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 0.8,
          max: 1.5,
          divisions: 14,
          label: context.l10n.common_percent((value * 100).toInt()),
          onChanged: (val) {
            unawaited(ref.read(appGlobalScaleProvider.notifier).set(val));
          },
        ),
      ],
    );
  }

  Widget _buildColorSelector() => Wrap(
    spacing: context.dimensions.spacingSmall,
    runSpacing: context.dimensions.spacingSmall,
    children: [
      ..._presetColors.map(_buildColorSwatch),
      _buildColorSwatch(null),
    ],
  );

  Future<void> _showCustomColorPicker() async {
    final color = await showDialog<Color>(
      context: context,
      builder: (context) => ThemeColorPickerDialog(initialColor: _seedColor),
    );
    if (!mounted || color == null) return;
    await _saveThemeColor(color);
  }

  Widget _buildColorSwatch(Color? color) {
    final isSelected = color == null
        ? !_presetColors.contains(_seedColor)
        : _seedColor == color;
    final displayColor = color ?? _seedColor;

    return Semantics(
      label: color == null
          ? context.l10n.settings_appearance_custom_hex
          : '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}',
      selected: isSelected,
      button: true,
      child: Padding(
        padding: EdgeInsets.only(right: context.dimensions.spacingSmall),
        child: InkWell(
          key: color == null ? const Key('custom-theme-color') : null,
          onTap: () {
            if (color != null) {
              unawaited(_saveThemeColor(color));
            } else {
              unawaited(_showCustomColorPicker());
            }
          },
          borderRadius: BorderRadius.circular(
            20 * context.dimensions.fontSizeFactor,
          ),
          child: Container(
            width: context.dimensions.buttonHeight.clamp(
              kMinInteractiveDimension,
              double.infinity,
            ),
            height: context.dimensions.buttonHeight.clamp(
              kMinInteractiveDimension,
              double.infinity,
            ),
            decoration: BoxDecoration(
              color: displayColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.2),
                width: isSelected ? 3 : 1,
              ),
            ),
            child: color == null && !isSelected
                ? Icon(
                    Icons.palette_outlined,
                    size: 20 * context.dimensions.fontSizeFactor,
                    color: displayColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                  )
                : isSelected
                ? Icon(
                    Icons.check,
                    size: 20 * context.dimensions.fontSizeFactor,
                    color: displayColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
