import 'package:flutter/material.dart';

import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/utils/l10n_extensions.dart';

/// Edits a temporary theme seed; the caller persists only the returned color.
class ThemeColorPickerDialog extends StatefulWidget {
  const ThemeColorPickerDialog({required this.initialColor, super.key});

  final Color initialColor;

  @override
  State<ThemeColorPickerDialog> createState() => _ThemeColorPickerDialogState();
}

class _ThemeColorPickerDialogState extends State<ThemeColorPickerDialog> {
  late HSVColor _color;
  late final TextEditingController _hex;
  bool _validHex = true;

  String _hexCode(Color color) =>
      color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();

  @override
  void initState() {
    super.initState();
    _color = HSVColor.fromColor(widget.initialColor);
    _hex = TextEditingController(text: _hexCode(widget.initialColor));
  }

  @override
  void dispose() {
    _hex.dispose();
    super.dispose();
  }

  void _setColor(HSVColor color) {
    setState(() {
      _color = color;
      _validHex = true;
      _hex.text = _hexCode(color.toColor());
    });
  }

  void _setHex(String input) {
    final hex = input.trim().replaceFirst(RegExp(r'^#'), '');
    final valid = RegExp(r'^(?:[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$').hasMatch(hex);
    setState(() {
      _validHex = valid;
      if (valid) {
        final value = int.parse(hex, radix: 16);
        _color = HSVColor.fromColor(
          Color(hex.length == 6 ? value | 0xFF000000 : value),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dims = context.dimensions;
    final l10n = context.l10n;
    return AlertDialog(
      insetPadding: EdgeInsets.all(dims.spacingMedium),
      title: Text(l10n.settings_appearance_primary_color),
      content: SizedBox(
        width: dims.buttonHeight * 7,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                key: const Key('theme-color-preview'),
                height: dims.buttonHeight,
                decoration: BoxDecoration(
                  color: _color.toColor(),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(color: context.colors.outline),
                ),
              ),
              SizedBox(height: dims.spacingMedium),
              _slider(
                label: l10n.settings_appearance_color_hue,
                value: _color.hue / 360,
                colors: [
                  for (var hue = 0; hue <= 360; hue += 60)
                    HSVColor.fromAHSV(1, hue.toDouble(), 1, 1).toColor(),
                ],
                onChanged: (value) => _setColor(_color.withHue(value * 360)),
              ),
              _slider(
                label: l10n.settings_appearance_color_saturation,
                value: _color.saturation,
                colors: [
                  _color.withSaturation(0).toColor(),
                  _color.withSaturation(1).toColor(),
                ],
                onChanged: (value) => _setColor(_color.withSaturation(value)),
              ),
              _slider(
                label: l10n.settings_appearance_color_brightness,
                value: _color.value,
                colors: [
                  _color.withValue(0).toColor(),
                  _color.withValue(1).toColor(),
                ],
                onChanged: (value) => _setColor(_color.withValue(value)),
              ),
              SizedBox(height: dims.spacingSmall),
              TextField(
                controller: _hex,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  labelText: l10n.settings_appearance_custom_hex,
                  prefixText: '#',
                  helperText: l10n.settings_appearance_custom_hex_helper,
                  errorText: _validHex
                      ? null
                      : l10n.settings_appearance_custom_hex_helper,
                  helperMaxLines: 3,
                  errorMaxLines: 3,
                ),
                onChanged: _setHex,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.common_cancel),
        ),
        FilledButton(
          onPressed: _validHex
              ? () => Navigator.pop(context, _color.toColor())
              : null,
          child: Text(l10n.common_apply),
        ),
      ],
    );
  }

  Widget _slider({
    required String label,
    required double value,
    required List<Color> colors,
    required ValueChanged<double> onChanged,
  }) {
    final dims = context.dimensions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: context.textTheme.labelLarge),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: dims.spacingSmall,
              margin: EdgeInsets.symmetric(horizontal: dims.spacingMedium),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
            ),
            Semantics(
              label: label,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  overlayShape: RoundSliderOverlayShape(
                    overlayRadius: dims.spacingMedium,
                  ),
                ),
                child: Slider(value: value, onChanged: onChanged),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
