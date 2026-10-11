import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import '../../../../../core/presentation/theme/app_theme.dart';
import '../../../../../core/utils/l10n_extensions.dart';
import '../../providers/video_player_provider.dart';

/// Read-only diagnostics, sampled only while the debug panel is mounted.
/// Unsupported mpv properties remain unavailable rather than implying zero.
class VideoDebugOverlay extends StatefulWidget {
  const VideoDebugOverlay({
    required this.player,
    required this.session,
    super.key,
  });

  final Player player;
  final GlobalPlayerState session;

  @override
  State<VideoDebugOverlay> createState() => _VideoDebugOverlayState();
}

class _VideoDebugOverlayState extends State<VideoDebugOverlay> {
  static const _properties = [
    'video-codec',
    'hwdec-current',
    'current-vo',
    'video-params/pixelformat',
    'container-fps',
    'estimated-vf-fps',
    'decoder-frame-drop-count',
    'frame-drop-count',
    'avsync',
    'demuxer-cache-duration',
  ];
  Timer? _timer;
  bool _sampling = false;
  Map<String, String> _values = {};

  @override
  void initState() {
    super.initState();
    unawaited(_sample());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _sample());
  }

  Future<void> _sample() async {
    if (_sampling) return;
    _sampling = true;
    final player = widget.player;
    final platform = player.platform;
    final values = <String, String>{};
    try {
      if (platform is NativePlayer) {
        for (final property in _properties) {
          try {
            values[property] = await platform.getProperty(
              property,
              waitForInitialization: false,
            );
          } on Object {
            // Properties may be absent or the session may be disposing.
          }
        }
      }
      if (mounted && identical(player, widget.player)) {
        setState(() => _values = values);
      }
    } finally {
      _sampling = false;
    }
  }

  @override
  void didUpdateWidget(VideoDebugOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.player, widget.player)) {
      _values = {};
      unawaited(_sample());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final d = context.dimensions;
    final state = widget.player.state;
    final session = widget.session;
    String value(String? raw) =>
        raw == null || raw.trim().isEmpty ? l10n.common_unavailable : raw;
    String metric(String property, String unit, {double factor = 1}) {
      final number = double.tryParse(_values[property] ?? '');
      return number == null || !number.isFinite
          ? l10n.common_unavailable
          : '${(number * factor).toStringAsFixed(2)} $unit';
    }

    Widget row(String label, String? raw) => Padding(
      padding: EdgeInsets.only(top: d.spacingSmall / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(color: Colors.white70)),
          ),
          SizedBox(width: d.spacingSmall),
          Expanded(flex: 3, child: Text(value(raw))),
        ],
      ),
    );
    Widget heading(String title) => Padding(
      padding: EdgeInsets.only(top: d.spacingSmall, bottom: d.spacingSmall / 2),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: d.spacingMedium,
        vertical: d.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(180),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DefaultTextStyle(
        style: context.textTheme.bodySmall!.copyWith(
          color: Colors.white,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              heading(l10n.scene_info_stream),
              row(l10n.video_debug_format, session.streamMimeType),
              if (session.streamLabel?.isNotEmpty == true)
                row(l10n.video_debug_variant, session.streamLabel),
              if (session.streamSource?.isNotEmpty == true)
                row(l10n.video_debug_source, session.streamSource),
              heading(l10n.video_debug_decoder),
              row(l10n.video_debug_codec, _values['video-codec']),
              row(l10n.video_debug_hardware, _values['hwdec-current']),
              row(l10n.video_debug_output, _values['current-vo']),
              row(
                l10n.common_resolution,
                state.width == null || state.height == null
                    ? null
                    : '${state.width} × ${state.height}',
              ),
              row(
                l10n.video_debug_pixel_format,
                _values['video-params/pixelformat'],
              ),
              heading(l10n.video_debug_performance),
              row(l10n.video_debug_source_fps, metric('container-fps', 'fps')),
              row(
                l10n.video_debug_output_fps,
                metric('estimated-vf-fps', 'fps'),
              ),
              row(
                l10n.video_debug_decoder_drops,
                _values['decoder-frame-drop-count'],
              ),
              row(l10n.video_debug_output_drops, _values['frame-drop-count']),
              row(
                l10n.video_debug_av_sync,
                metric('avsync', 'ms', factor: 1000),
              ),
              row(
                l10n.video_debug_cache,
                metric('demuxer-cache-duration', 's'),
              ),
              row(
                l10n.video_debug_buffer,
                '${(math.max(0, (state.buffer - state.position).inMilliseconds) / 1000).toStringAsFixed(2)} s',
              ),
              row(
                l10n.common_playback_speed,
                '${state.rate.toStringAsFixed(2)}×',
              ),
              row(
                l10n.video_debug_startup,
                session.startupLatencyMs == null
                    ? null
                    : '${session.startupLatencyMs} ms',
              ),
              if (session.prewarmAttempted == true)
                row(
                  l10n.video_debug_prewarm,
                  '${session.prewarmSucceeded == true ? l10n.video_debug_success : l10n.video_debug_failed}${session.prewarmLatencyMs == null ? '' : ' · ${session.prewarmLatencyMs} ms'}',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
