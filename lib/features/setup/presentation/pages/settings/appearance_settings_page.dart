import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import 'package:stash_app_flutter/core/presentation/theme/theme_mode_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/theme_color_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/true_black_provider.dart';
import 'package:stash_app_flutter/core/presentation/providers/layout_settings_provider.dart';
import '../../widgets/settings_page_shell.dart';

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

  final _customHexController = TextEditingController();
  final _customHexFocusNode = FocusNode();
  Color _seedColor = const Color(0xFF0F766E);
  bool _forceShowCustom = false;
  ThemeMode _themeMode = ThemeMode.system;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _customHexFocusNode.addListener(_onTextFieldFocusChanged);
    _load();
  }

  void _onTextFieldFocusChanged() {
    if (_customHexFocusNode.hasFocus) {
      return;
    }
  }

  Future<void> _load() async {
    final themeMode = ref.read(appThemeModeProvider);
    final seedColor = ref.read(appThemeColorProvider);

    _themeMode = themeMode;
    _seedColor = seedColor;

    if (!_presetColors.contains(seedColor)) {
      _customHexController.text = seedColor
          .toARGB32()
          .toUnsigned(32)
          .toRadixString(16)
          .padLeft(8, '0')
          .toUpperCase();
    }

    setState(() => _loading = false);
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    await ref.read(appThemeModeProvider.notifier).setThemeMode(mode);
  }

  Future<void> _saveThemeColor(Color color) async {
    setState(() {
      _seedColor = color;
      _forceShowCustom = false;
    });
    await ref.read(appThemeColorProvider.notifier).setThemeColor(color);
  }

  @override
  void dispose() {
    _customHexController.dispose();
    _customHexFocusNode
      ..removeListener(_onTextFieldFocusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SettingsPageShell(
      title: l10n.settings_appearance_title,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SettingsSectionCard(
                    title: l10n.settings_appearance_theme_mode,
                    subtitle: l10n.settings_appearance_theme_mode_subtitle,
                    child: Column(
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
                                icon: const Icon(Icons.brightness_auto_outlined),
                                label: Text(l10n.settings_appearance_theme_system),
                              ),
                              ButtonSegment<ThemeMode>(
                                value: ThemeMode.light,
                                icon: const Icon(Icons.light_mode_outlined),
                                label: Text(l10n.settings_appearance_theme_light),
                              ),
                              ButtonSegment<ThemeMode>(
                                value: ThemeMode.dark,
                                icon: const Icon(Icons.dark_mode_outlined),
                                label: Text(l10n.settings_appearance_theme_dark),
                              ),
                            ],
                            selected: {_themeMode},
                            onSelectionChanged: (selection) {
                              _saveThemeMode(selection.first);
                            },
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingMedium),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.settings_appearance_true_black),
                          subtitle: Text(
                            l10n.settings_appearance_true_black_subtitle,
                          ),
                          value: ref.watch(trueBlackEnabledProvider),
                          onChanged: (value) {
                            ref
                                .read(trueBlackEnabledProvider.notifier)
                                .set(value);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  SettingsSectionCard(
                    title: l10n.settings_appearance_primary_color,
                    subtitle: l10n.settings_appearance_primary_color_subtitle,
                    child: _buildColorSelector(),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  SettingsSectionCard(
                    title: l10n.settings_appearance_font_size,
                    subtitle: l10n.settings_appearance_font_size_subtitle,
                    child: _buildFontSizeFactorSlider(l10n),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFontSizeFactorSlider(AppLocalizations l10n) {
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
              onPressed:
                  value == 1.0
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
          label: '${(value * 100).toInt()}%',
          onChanged: (val) {
            ref.read(appGlobalScaleProvider.notifier).set(val);
          },
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    final isCustom = _forceShowCustom || !_presetColors.contains(_seedColor);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppTheme.spacingSmall,
          runSpacing: AppTheme.spacingSmall,
          children: [
            ..._presetColors.map((color) => _buildColorSwatch(color)),
            _buildColorSwatch(null),
          ],
        ),
        if (isCustom) ...[
          const SizedBox(height: AppTheme.spacingMedium),
          TextField(
            controller: _customHexController,
            focusNode: _customHexFocusNode,
            decoration: InputDecoration(
              labelText: l10n.settings_appearance_custom_hex,
              hintText: 'FF0F766E',
              prefixText: '#',
              helperText: l10n.settings_appearance_custom_hex_helper,
            ),
            maxLength: 8,
            onChanged: (value) {
              if (value.length == 8) {
                final colorValue = int.tryParse(value, radix: 16);
                if (colorValue != null) {
                  _seedColor = Color(colorValue);
                  ref
                      .read(appThemeColorProvider.notifier)
                      .setThemeColor(_seedColor);
                }
              }
            },
          ),
        ],
      ],
    );
  }

  Widget _buildColorSwatch(Color? color) {
    final isSelected = color == null
        ? (_forceShowCustom || !_presetColors.contains(_seedColor))
        : (_seedColor == color && !_forceShowCustom);
    final displayColor = color ?? _seedColor;

    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.spacingSmall),
      child: InkWell(
        onTap: () {
          if (color != null) {
            _saveThemeColor(color);
          } else {
            setState(() {
              _forceShowCustom = true;
              if (_customHexController.text.isEmpty) {
                _customHexController.text = _seedColor
                    .toARGB32()
                    .toUnsigned(32)
                    .toRadixString(16)
                    .padLeft(8, '0')
                    .toUpperCase();
              }
            });
            _customHexFocusNode.requestFocus();
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
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
                  size: 20,
                  color: displayColor.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                )
              : isSelected
              ? Icon(
                  Icons.check,
                  size: 20,
                  color: displayColor.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                )
              : null,
        ),
      ),
    );
  }
}
