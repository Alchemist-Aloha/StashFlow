import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/presentation/theme/theme_mode_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/theme_color_provider.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Appearance Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Theme Mode'),
                  const SizedBox(height: AppTheme.spacingSmall),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      showSelectedIcon: false,
                      style: ButtonStyle(visualDensity: VisualDensity.compact),
                      segments: const [
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.system,
                          icon: Icon(Icons.brightness_auto_outlined),
                          label: Text('System'),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode_outlined),
                          label: Text('Light'),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode_outlined),
                          label: Text('Dark'),
                        ),
                      ],
                      selected: {_themeMode},
                      onSelectionChanged: (selection) {
                        final selected = selection.first;
                        _saveThemeMode(selected);
                      },
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildSectionHeader('Primary Color'),
                  const SizedBox(height: AppTheme.spacingSmall),
                  _buildColorSelector(),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    final isCustom = _forceShowCustom || !_presetColors.contains(_seedColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ..._presetColors.map((color) => _buildColorSwatch(color)),
              _buildColorSwatch(null), // Custom
            ],
          ),
        ),
        if (isCustom) ...[
          const SizedBox(height: AppTheme.spacingMedium),
          TextField(
            controller: _customHexController,
            focusNode: _customHexFocusNode,
            decoration: const InputDecoration(
              labelText: 'Custom Hex Color',
              hintText: 'FF0F766E',
              prefixText: '#',
              helperText: 'Enter an 8-digit ARGB hex code',
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
