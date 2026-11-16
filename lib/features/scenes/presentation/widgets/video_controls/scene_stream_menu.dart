import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../../core/data/services/cast_service.dart';
import '../../../../../core/presentation/theme/app_theme.dart';
import '../../../../../core/utils/app_log_store.dart';
import '../../../../../core/utils/l10n_extensions.dart';
import '../../../data/repositories/playback_media.dart';
import '../../../data/repositories/stream_resolver.dart';
import '../../../domain/entities/scene.dart';
import '../../providers/video_player_provider.dart';

/// Stash's `resolution` query value; direct streams count as original.
String? _resolution(String url) =>
    Uri.tryParse(url)?.queryParameters['resolution'] ?? 'ORIGINAL';

/// Server labels are the format then the resolution, e.g. "MP4 HD (720p)".
String _resolutionLabel(BuildContext context, StreamChoice s) {
  final rest = (s.label ?? '').split(' ').skip(1).join(' ').trim();
  return rest.isEmpty ? context.l10n.player_stream_original : rest;
}

/// Shared source picker that reopens [controller]'s player on another
/// `sceneStreams` endpoint at the current position.
///
/// Source and resolution are staged in a two-column panel; Apply or any
/// dismissal commits the staged stream.
class SceneStreamMenu extends ConsumerStatefulWidget {
  const SceneStreamMenu({
    super.key,
    required this.controller,
    required this.scene,
    this.onInteract,
  });
  final VideoController controller;
  final Scene scene;
  final VoidCallback? onInteract;

  @override
  ConsumerState<SceneStreamMenu> createState() => _SceneStreamMenuState();
}

class _SceneStreamMenuState extends ConsumerState<SceneStreamMenu> {
  /// Selection staged by the open panel; committed when it closes.
  StreamChoice? _pending;

  String? get _currentUrl =>
      widget.controller.player.state.playlist.medias.firstOrNull?.uri;

  void _commit(StreamChoice? choice) {
    _pending = null;
    widget.onInteract?.call();
    final current = _currentUrl;
    if (choice == null ||
        (current != null && _sameStream(choice.url, current))) {
      return;
    }
    unawaited(_switchTo(choice));
  }

  Future<void> _switchTo(StreamChoice choice) async {
    final player = widget.controller.player;
    final url = ref.read(webMediaUrlProvider)(choice.url);
    final position = player.state.position;
    final playing = player.state.playing;
    AppLogStore.instance.add(
      'switch stream scene=${widget.scene.id} label=${choice.label} at=${position.inMilliseconds}ms',
      source: 'stream_menu',
    );
    // Read before awaiting: the menu may unmount while the stream reopens.
    final owned = identical(ref.read(playerStateProvider).player, player);
    final notifier = ref.read(playerStateProvider.notifier);
    final subtitle = player.state.track.subtitle;
    await player.open(
      createPlaybackMedia(
        url,
        httpHeaders: ref.read(mediaPlaybackHeadersProvider),
        start: position,
        duration: sceneFileDuration(widget.scene),
      ),
      play: playing,
    );
    // Reopening drops external subtitle tracks; restore the active one.
    if (subtitle.uri || subtitle.data) await player.setSubtitleTrack(subtitle);
    if (owned) notifier.setActiveStream(choice);
  }

  @override
  Widget build(BuildContext context) {
    final streams =
        ref.watch(sceneStreamsProvider(widget.scene.id)).value ?? const [];
    final casting = ref.watch(castServiceProvider.select((s) => s.isCasting));
    final theme = Theme.of(context).colorScheme;
    return PopupMenuButton<StreamChoice>(
      tooltip: context.l10n.player_stream_source,
      enabled: streams.isNotEmpty && !casting,
      color: theme.surfaceContainerHigh,
      constraints: BoxConstraints(
        maxWidth: 420 * context.dimensions.fontSizeFactor,
      ),
      onOpened: widget.onInteract,
      onSelected: _commit,
      onCanceled: () => _commit(_pending),
      itemBuilder: (_) => [
        _StreamPickerEntry(
          streams: streams,
          currentUrl: _currentUrl,
          onChanged: (choice) => _pending = choice,
        ),
      ],
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: context.dimensions.buttonHeight,
          minHeight: context.dimensions.buttonHeight,
        ),
        child: Icon(
          Icons.tune_rounded,
          size: 24 * context.dimensions.fontSizeFactor,
          color: streams.isEmpty || casting ? Colors.white54 : Colors.white,
        ),
      ),
    );
  }
}

bool _sameStream(String a, String b) =>
    streamSourceKind(a) == streamSourceKind(b) &&
    _resolution(a) == _resolution(b);

/// The two-column source/resolution panel shown as the menu's only entry.
class _StreamPickerEntry extends PopupMenuEntry<StreamChoice> {
  const _StreamPickerEntry({
    required this.streams,
    required this.currentUrl,
    required this.onChanged,
  });
  final List<StreamChoice> streams;
  final String? currentUrl;
  final ValueChanged<StreamChoice> onChanged;

  @override
  double get height => 0;

  @override
  bool represents(StreamChoice? value) => false;

  @override
  State<_StreamPickerEntry> createState() => _StreamPickerEntryState();
}

class _StreamPickerEntryState extends State<_StreamPickerEntry> {
  late String _kind;
  late String? _res;

  @override
  void initState() {
    super.initState();
    final current = widget.currentUrl;
    _kind = current == null ? 'direct' : streamSourceKind(current);
    _res = current == null ? 'ORIGINAL' : _resolution(current);
  }

  List<StreamChoice> _of(String kind) =>
      widget.streams.where((s) => streamSourceKind(s.url) == kind).toList();

  /// Resolution options, taken from the first transcoded format for Direct.
  List<StreamChoice> get _resOptions {
    if (_kind != 'direct') return _of(_kind);
    return streamSourceKinds
        .skip(1)
        .map(_of)
        .firstWhere((o) => o.isNotEmpty, orElse: () => const []);
  }

  StreamChoice get _selected {
    final options = _of(_kind);
    return options.where((s) => _resolution(s.url) == _res).firstOrNull ??
        options.first;
  }

  void _update(VoidCallback change) {
    setState(change);
    widget.onChanged(_selected);
  }

  Widget _option(
    BuildContext context, {
    required String label,
    required bool selected,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context).colorScheme;
    final color = onTap == null
        ? theme.onSurface.withValues(alpha: 0.38)
        : selected
        ? theme.primary
        : theme.onSurface;
    return Semantics(
      selected: selected,
      button: true,
      enabled: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.dimensions.spacingSmall),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: context.dimensions.buttonHeight,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.dimensions.spacingSmall,
            ),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 20 * context.dimensions.fontSizeFactor,
                  color: color,
                ),
                SizedBox(width: context.dimensions.spacingSmall),
                Flexible(
                  child: Text(
                    label,
                    style: context.textTheme.bodyMedium?.copyWith(color: color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _column(BuildContext context, String title, List<Widget> options) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(context.dimensions.spacingSmall),
            child: Text(
              title,
              style: context.textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ...options,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final direct = _kind == 'direct';
    final spacing = context.dimensions.spacingSmall;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _column(context, context.l10n.player_stream_source, [
                  for (final kind in streamSourceKinds)
                    if (_of(kind).isNotEmpty)
                      _option(
                        context,
                        label: kind == 'direct'
                            ? context.l10n.player_stream_direct
                            : kind.toUpperCase(),
                        selected: kind == _kind,
                        onTap: () => _update(() => _kind = kind),
                      ),
                ]),
                const VerticalDivider(width: 1),
                _column(context, context.l10n.player_stream_resolution, [
                  for (final s in _resOptions)
                    _option(
                      context,
                      label: _resolutionLabel(context, s),
                      selected: !direct && _resolution(s.url) == _res,
                      onTap: direct
                          ? null
                          : () => _update(() => _res = _resolution(s.url)),
                    ),
                ]),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: spacing),
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(_selected),
              child: Text(context.l10n.common_apply),
            ),
          ),
        ],
      ),
    );
  }
}
