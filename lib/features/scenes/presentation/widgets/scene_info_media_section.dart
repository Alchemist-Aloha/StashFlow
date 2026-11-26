import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/presentation/widgets/section_panel.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../domain/entities/scene.dart';
import '../../data/repositories/preview_availability_service.dart';
import '../../data/repositories/playback_media.dart';
import '../providers/player_settings.dart';
import 'scene_cover_fullscreen_viewer.dart';
import 'preview_video_controls_theme.dart';
import '../../../../core/utils/app_log_store.dart';

typedef SceneInfoMediaBuilder = Widget Function(
  BuildContext context,
  Scene scene,
);
typedef SceneInfoPreviewBuilder = Widget Function(
  BuildContext context,
  Scene scene,
  bool autoplay,
  VoidCallback onUnavailable,
);

enum _SceneInfoMediaMode { cover, preview }

class SceneInfoMediaSection extends ConsumerStatefulWidget {
  const SceneInfoMediaSection({
    required this.scene,
    this.coverBuilder,
    this.previewBuilder,
    super.key,
  });

  final Scene scene;
  final SceneInfoMediaBuilder? coverBuilder;
  final SceneInfoPreviewBuilder? previewBuilder;

  static bool isVisibleFor(Scene scene) {
    return _normalized(scene.paths.screenshot) != null ||
        _normalized(scene.paths.preview) != null;
  }

  static String? _normalized(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }

  @override
  ConsumerState<SceneInfoMediaSection> createState() =>
      _SceneInfoMediaSectionState();
}

class _SceneInfoMediaSectionState extends ConsumerState<SceneInfoMediaSection> {
  late _SceneInfoMediaMode _mode = _initialMode(widget.scene);
  late bool _previewAutoplay = _mode == _SceneInfoMediaMode.preview;

  /// False once the preview is known to be missing or unplayable. Only the
  /// toggle listens, so a failed probe never redraws a shown cover.
  late final _previewAvailable = ValueNotifier<bool>(_previewUrl != null);
  int _availabilityGeneration = 0;

  String? get _coverUrl =>
      SceneInfoMediaSection._normalized(widget.scene.paths.screenshot);
  String? get _previewUrl =>
      SceneInfoMediaSection._normalized(widget.scene.paths.preview);

  static _SceneInfoMediaMode _initialMode(Scene scene) {
    return SceneInfoMediaSection._normalized(scene.paths.screenshot) != null
        ? _SceneInfoMediaMode.cover
        : _SceneInfoMediaMode.preview;
  }

  Future<void> _showFullscreenCover(String coverUrl) {
    return showGeneralDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return SceneCoverFullscreenViewer(
          imageUrl: coverUrl,
          imageBuilder: widget.coverBuilder == null
              ? null
              : (viewerContext, imageUrl) =>
                    widget.coverBuilder!(viewerContext, widget.scene),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _checkPreviewAvailability();
  }

  @override
  void dispose() {
    _previewAvailable.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SceneInfoMediaSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene.id != widget.scene.id ||
        oldWidget.scene.paths.screenshot != widget.scene.paths.screenshot ||
        oldWidget.scene.paths.preview != widget.scene.paths.preview) {
      _mode = _initialMode(widget.scene);
      _previewAutoplay = _mode == _SceneInfoMediaMode.preview;
      _previewAvailable.value = _previewUrl != null;
      _checkPreviewAvailability();
    }
  }

  /// Probes the preview URL in the background when the sheet opens; the
  /// preview segment stays selectable until the probe says otherwise.
  void _checkPreviewAvailability() {
    final previewUrl = _previewUrl;
    if (previewUrl == null) return;

    final generation = ++_availabilityGeneration;
    unawaited(
      ref
          .read(previewAvailabilityCheckProvider)(previewUrl)
          .then((available) {
            if (!available &&
                mounted &&
                generation == _availabilityGeneration) {
              _markPreviewUnavailable();
            }
          })
          .catchError((Object error, StackTrace stackTrace) {
            // An unverifiable preview stays selectable; playback reports
            // failures itself.
            AppLogStore.instance.addError(
              'Verify preview availability',
              error,
              stackTrace,
              source: 'scene_info_media_section',
            );
          }),
    );
  }

  /// Disables the preview segment; redraws the media only if it shows the
  /// preview, falling back to the cover when there is one.
  void _markPreviewUnavailable() {
    if (!mounted || !_previewAvailable.value) return;
    _previewAvailable.value = false;
    if (_mode != _SceneInfoMediaMode.preview) return;
    setState(() {
      if (_coverUrl != null) {
        _mode = _SceneInfoMediaMode.cover;
        _previewAutoplay = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final coverUrl = _coverUrl;
    final previewUrl = _previewUrl;
    if (coverUrl == null && previewUrl == null) {
      return const SizedBox.shrink();
    }

    final showCover = coverUrl != null && _mode == _SceneInfoMediaMode.cover;
    final previewUnavailable = !showCover && !_previewAvailable.value;

    return SectionPanel(
      key: const Key('scene_info_media_section'),
      title: context.l10n.preview,
      titleTrailing: ValueListenableBuilder<bool>(
        valueListenable: _previewAvailable,
        builder: (context, previewAvailable, _) =>
            SegmentedButton<_SceneInfoMediaMode>(
              key: const Key('scene_info_media_toggle'),
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: _SceneInfoMediaMode.cover,
                  label: Text(context.l10n.scene_info_cover),
                  icon: const Icon(Icons.image_outlined),
                  enabled: coverUrl != null,
                ),
                ButtonSegment(
                  value: _SceneInfoMediaMode.preview,
                  label: Text(context.l10n.preview),
                  icon: const Icon(Icons.play_circle_outline),
                  enabled: previewAvailable,
                  tooltip: previewAvailable
                      ? null
                      : context.l10n.scene_info_preview_unavailable,
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (selection) {
                setState(() {
                  _mode = selection.single;
                  _previewAutoplay = _mode == _SceneInfoMediaMode.preview;
                });
              },
            ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ColoredBox(
          color: Colors.black,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: showCover
                ? Semantics(
                    button: true,
                    label: context.l10n.scene_info_cover,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        key: const Key('scene_info_media_cover_tap_target'),
                        onTap: () => _showFullscreenCover(coverUrl),
                        child: KeyedSubtree(
                          key: const Key('scene_info_media_cover'),
                          child:
                              widget.coverBuilder?.call(
                                context,
                                widget.scene,
                              ) ??
                              StashImage(
                                imageUrl: coverUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.contain,
                              ),
                        ),
                      ),
                    ),
                  )
                : previewUnavailable
                ? const _SceneInfoPreviewUnavailable(
                    key: Key('scene_info_media_preview_unavailable'),
                  )
                : KeyedSubtree(
                    key: const Key('scene_info_media_preview'),
                    child:
                        widget.previewBuilder?.call(
                          context,
                          widget.scene,
                          _previewAutoplay,
                          _markPreviewUnavailable,
                        ) ??
                        _SceneInfoPreviewPlayer(
                          key: ValueKey(
                            'scene_info_preview_${widget.scene.id}_$previewUrl',
                          ),
                          previewUrl: previewUrl!,
                          autoplay: _previewAutoplay,
                          onUnavailable: _markPreviewUnavailable,
                        ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _SceneInfoPreviewUnavailable extends StatelessWidget {
  const _SceneInfoPreviewUnavailable({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.videocam_off_outlined,
            color: Colors.white54,
            size: 36,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              context.l10n.scene_info_preview_unavailable,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

class _SceneInfoPreviewPlayer extends ConsumerStatefulWidget {
  const _SceneInfoPreviewPlayer({
    required this.previewUrl,
    required this.autoplay,
    required this.onUnavailable,
    super.key,
  });

  final String previewUrl;
  final bool autoplay;

  /// Invoked when the preview cannot be loaded or played so the surrounding
  /// section can present a fallback instead of an unusable player surface.
  final VoidCallback onUnavailable;

  @override
  ConsumerState<_SceneInfoPreviewPlayer> createState() =>
      _SceneInfoPreviewPlayerState();
}

class _SceneInfoPreviewPlayerState
    extends ConsumerState<_SceneInfoPreviewPlayer> {
  /// Upper bound for a preview that never finishes loading (for example a
  /// server that accepts the request but never returns media).
  static const Duration _startupTimeout = Duration(seconds: 12);

  Player? _player;
  VideoController? _controller;
  StreamSubscription<Object>? _errorSubscription;
  Timer? _startupWatchdog;
  bool _initializing = true;
  bool _reportedUnavailable = false;

  @override
  void initState() {
    super.initState();
    unawaited(_initialize());
  }

  @override
  void dispose() {
    unawaited(_disposePlayer());
    super.dispose();
  }

  void _reportUnavailable() {
    if (_reportedUnavailable || !mounted) return;
    _reportedUnavailable = true;
    widget.onUnavailable();
  }

  Future<void> _initialize() async {
    final player = Player();
    final controller = VideoController(
      player,
      configuration: PlayerSettingsStore(ref.read(sharedPreferencesProvider))
          .loadVideoConfiguration(),
    );
    _player = player;
    _controller = controller;

    _errorSubscription = player.stream.error.listen(
      (_) => _reportUnavailable(),
    );
    _startupWatchdog = Timer(_startupTimeout, () {
      if (mounted && _initializing && !_reportedUnavailable) {
        _reportUnavailable();
      }
    });

    try {
      final graphqlEndpoint = Uri.tryParse(ref.read(serverUrlProvider));
      var effectiveUrl = graphqlEndpoint == null
          ? widget.previewUrl
          : resolveGraphqlMediaUrl(
              rawUrl: widget.previewUrl,
              graphqlEndpoint: graphqlEndpoint,
            );
      final effectiveHeaders = ref.read(mediaPlaybackHeadersProvider);

      effectiveUrl = ref.read(webMediaUrlProvider)(effectiveUrl);

      await PlayerSettingsStore(ref.read(sharedPreferencesProvider))
          .applyMpvProperties(player);
      await player.open(
        createPlaybackMedia(effectiveUrl, httpHeaders: effectiveHeaders),
        play: widget.autoplay,
      );
    } on Object catch (error, stackTrace) {
      AppLogStore.instance.addError(
        'initialize',
        error,
        stackTrace,
        source: 'scene_info_media_section',
      );
      // Playback recovery must also handle non-Exception plugin failures.
      _reportUnavailable();
    } finally {
      if (mounted) {
        setState(() => _initializing = false);
      }
    }
  }

  Future<void> _disposePlayer() async {
    _startupWatchdog?.cancel();
    _startupWatchdog = null;
    await _errorSubscription?.cancel();
    _errorSubscription = null;
    final player = _player;
    _player = null;
    _controller = null;
    await player?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (controller != null)
          PreviewVideoControlsTheme(child: Video(controller: controller)),
        if (_initializing) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
