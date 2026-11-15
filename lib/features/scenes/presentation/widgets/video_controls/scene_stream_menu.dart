import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../../core/data/auth/auth_provider.dart';
import '../../../../../core/data/graphql/graphql_client.dart';
import '../../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../../core/data/graphql/url_resolver.dart';
import '../../../../../core/data/services/cast_service.dart';
import '../../../../../core/presentation/theme/app_theme.dart';
import '../../../../../core/utils/app_log_store.dart';
import '../../../../../core/utils/l10n_extensions.dart';
import '../../../data/repositories/playback_media.dart';
import '../../../data/repositories/stream_resolver.dart';
import '../../../domain/entities/scene.dart';
import '../../providers/video_player_provider.dart';

/// Identifies a Stash stream independent of auth query parameters.
String _streamKey(String url) {
  final uri = Uri.tryParse(url);
  return '${uri?.path}?${uri?.queryParameters['resolution']}';
}

/// Shared source picker that reopens [controller]'s player on another
/// `sceneStreams` endpoint at the current position.
class SceneStreamMenu extends ConsumerWidget {
  const SceneStreamMenu({
    super.key,
    required this.controller,
    required this.scene,
    this.onInteract,
  });
  final VideoController controller;
  final Scene scene;
  final VoidCallback? onInteract;

  Future<void> _switchTo(WidgetRef ref, StreamChoice choice) async {
    final player = controller.player;
    var url = choice.url;
    if (kIsWeb) {
      final auth = ref.read(authProvider);
      url = applyWebMediaAuthFallback(
        url: url,
        authMode: auth.mode,
        apiKey: ref.read(serverApiKeyProvider),
        username: auth.username,
        password: auth.password,
        graphqlEndpoint: Uri.tryParse(ref.read(serverUrlProvider)),
      );
    }
    final position = player.state.position;
    final playing = player.state.playing;
    AppLogStore.instance.add(
      'switch stream scene=${scene.id} label=${choice.label} at=${position.inMilliseconds}ms',
      source: 'stream_menu',
    );
    // Read before awaiting: the menu may unmount while the stream reopens.
    final owned = identical(ref.read(playerStateProvider).player, player);
    final notifier = ref.read(playerStateProvider.notifier);
    await player.open(
      createPlaybackMedia(
        url,
        httpHeaders: ref.read(mediaPlaybackHeadersProvider),
        start: position,
      ),
      play: playing,
    );
    if (owned) notifier.setActiveStream(choice);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streams = ref.watch(sceneStreamsProvider(scene.id)).value ?? const [];
    final casting = ref.watch(castServiceProvider.select((s) => s.isCasting));
    final theme = Theme.of(context).colorScheme;
    return PopupMenuButton<StreamChoice>(
      tooltip: context.l10n.player_stream_source,
      enabled: streams.isNotEmpty && !casting,
      color: theme.surfaceContainerHigh,
      onOpened: onInteract,
      onSelected: (choice) {
        onInteract?.call();
        unawaited(_switchTo(ref, choice));
      },
      itemBuilder: (_) {
        final current = controller.player.state.playlist.medias.firstOrNull;
        final currentKey = current == null ? null : _streamKey(current.uri);
        return [
          for (final s in streams)
            CheckedPopupMenuItem(
              value: s,
              checked: _streamKey(s.url) == currentKey,
              child: Text(s.label ?? s.mimeType),
            ),
        ];
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: context.dimensions.buttonHeight,
          minHeight: context.dimensions.buttonHeight,
        ),
        child: Icon(
          Icons.high_quality_rounded,
          size: 24 * context.dimensions.fontSizeFactor,
          color: streams.isEmpty || casting ? Colors.white54 : Colors.white,
        ),
      ),
    );
  }
}
