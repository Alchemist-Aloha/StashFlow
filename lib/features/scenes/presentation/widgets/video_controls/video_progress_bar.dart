import 'package:flutter/material.dart';

class VideoProgressBar extends StatelessWidget {
  const VideoProgressBar({
    super.key,
    required this.durationMs,
    required this.positionStream,
    required this.initialPositionMs,
    required this.isScrubbing,
    required this.currentScrubValue,
    required this.onChangeStart,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final int durationMs;
  final Stream<Duration> positionStream;
  final double initialPositionMs;
  final bool isScrubbing;
  final double currentScrubValue;
  final ValueChanged<double> onChangeStart;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 3,
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        StreamBuilder<Duration>(
          stream: positionStream,
          builder: (context, snapshot) {
            final positionMs = isScrubbing
                ? currentScrubValue
                : (snapshot.data?.inMilliseconds.toDouble() ?? initialPositionMs);
            
            return SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: colorScheme.primary,
                inactiveTrackColor: colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.25,
                ),
                thumbColor: colorScheme.primary,
              ),
              child: Slider(
                min: 0,
                max: durationMs.toDouble(),
                value: positionMs.clamp(0, durationMs.toDouble()),
                onChangeStart: onChangeStart,
                onChanged: onChanged,
                onChangeEnd: onChangeEnd,
              ),
            );
          },
        ),
      ],
    );
  }
}
