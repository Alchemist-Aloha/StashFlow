import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/data/services/cast_service.dart';
import '../../data/local_captions/caption_audio_decoder.dart';
import '../../data/local_captions/caption_session.dart';
import '../../data/local_captions/caption_worker.dart';
import 'local_caption_settings.dart';
import 'video_player_provider.dart';
export '../../data/local_captions/caption_session.dart'
    show CaptionFrame, CaptionStatus;

enum LocalCaptionMode { off, transcribe, translate }

class LocalCaptions {
  const LocalCaptions({
    this.mode = LocalCaptionMode.off,
    this.player,
    this.frame = const CaptionFrame(CaptionStatus.ready),
  });
  final LocalCaptionMode mode;
  final Player? player;
  final CaptionFrame frame;
}

final localCaptionsProvider =
    NotifierProvider<LocalCaptionsNotifier, LocalCaptions>(
      LocalCaptionsNotifier.new,
    );

/// Route-independent ownership: generated captions belong to one global scene,
/// audio track and model pair. No recording permission or microphone is involved.
class LocalCaptionsNotifier extends Notifier<LocalCaptions> {
  int _generation = 0;
  CaptionSession? _session;
  CaptionWorker? _worker;
  Future<CaptionWorker>? _opening;
  CaptionAudioDecoder? _decoder;
  // Session-owned: captured and cancelled by _release before closing the worker.
  // ignore: cancel_subscriptions
  StreamSubscription<Track>? _track;
  Future<void> _cleanup = Future.value();

  @override
  LocalCaptions build() {
    ref.onDispose(() => unawaited(_release()));
    ref.listen(
      playerStateProvider.select((s) => (s.player, s.activeScene?.id)),
      (_, next) => unawaited(stop()),
    );
    ref.listen(playerStateProvider.select((s) => s.selectedSubtitleLanguage), (
      _,
      next,
    ) {
      if (next != null && next != 'none') {
        unawaited(stop());
      }
    });
    ref.listen(
      localCaptionSettingsProvider.select(
        (s) => (s.selected, s.translation, s.canTranscribe, s.canTranslate),
      ),
      (_, next) => unawaited(stop()),
    );
    ref.listen(castServiceProvider.select((s) => s.isCasting), (_, casting) {
      if (casting) unawaited(stop());
    });
    ref.listen(mediaPlaybackHeadersProvider, (_, next) => unawaited(stop()));
    return const LocalCaptions();
  }

  Future<void> _release() {
    ++_generation;
    final session = _session;
    final worker = _worker;
    final opening = _opening;
    final track = _track;
    _decoder?.close();
    _session = null;
    _worker = null;
    _opening = null;
    _track = null;
    _decoder = null;
    final pending = session?.close();
    _cleanup = _cleanup
        .then((_) async {
          await track?.cancel();
          try {
            await pending;
          } finally {
            final ownedWorker = worker ?? await opening;
            await ownedWorker?.close();
          }
        })
        .catchError((Object _) {
          // Native cleanup errors must not revive captions or interrupt playback.
        });
    return _cleanup;
  }

  Future<void> stop() {
    final released = _release();
    if (ref.mounted) state = const LocalCaptions();
    return released;
  }

  Future<void> setMode(LocalCaptionMode mode) async {
    final released = stop();
    final request = _generation;
    await released;
    if (!ref.mounted ||
        request != _generation ||
        mode == LocalCaptionMode.off ||
        !localCaptionsSupported) {
      return;
    }
    final settings = ref.read(localCaptionSettingsProvider);
    final playback = ref.read(playerStateProvider);
    final player = playback.player;
    if (!settings.canTranscribe ||
        player == null ||
        playback.activeScene == null ||
        ref.read(castServiceProvider).isCasting ||
        (mode == LocalCaptionMode.translate && !settings.canTranslate)) {
      return;
    }
    final playlist = player.state.playlist;
    if (playlist.medias.isEmpty) return;
    final media = playlist.medias[playlist.index];
    final generation = ++_generation;
    state = LocalCaptions(
      mode: mode,
      player: player,
      frame: const CaptionFrame(CaptionStatus.preparing),
    );
    try {
      await ref.read(playerStateProvider.notifier).setSubtitle('none');
      final model = settings.model!;
      final translation = mode == LocalCaptionMode.translate
          ? settings.translationModel
          : null;
      final store = await ref.read(captionModelStoreProvider.future);
      if (!await store.isInstalled(model) ||
          (translation != null && !await store.isInstalled(translation))) {
        throw StateError('Caption model unavailable');
      }
      final temporary = await getTemporaryDirectory();
      if (!ref.mounted || generation != _generation) return;
      final opening = _opening = CaptionWorker.start(
        model,
        store.directory(model).path,
        translation: translation,
        translationDirectory: translation == null
            ? null
            : store.directory(translation).path,
      );
      final worker = await opening;
      // A stop during initialization transfers cleanup ownership to _release.
      if (!ref.mounted || generation != _generation) return;
      _opening = null;
      _worker = worker;
      final decoder = _decoder = CaptionAudioDecoder();
      final headers = Map<String, String>.of(
        media.httpHeaders ?? ref.read(mediaPlaybackHeadersProvider),
      );
      final audioTrack = player.state.track.audio.id;
      final session = _session = CaptionSession(
        position: () => player.state.position,
        duration: () => player.state.duration,
        cancelDecode: decoder.cancel,
        onFrame: (frame) {
          if (ref.mounted && generation == _generation) {
            state = LocalCaptions(mode: mode, player: player, frame: frame);
          }
        },
        process: (start, end) async {
          final audioStart = start > const Duration(seconds: 1)
              ? start - const Duration(seconds: 1)
              : Duration.zero;
          var audioEnd = end + const Duration(seconds: 1);
          final duration = player.state.duration;
          if (duration > Duration.zero && audioEnd > duration) {
            audioEnd = duration;
          }
          final samples = await decoder.read(
            url: media.uri,
            headers: headers,
            start: audioStart,
            end: audioEnd,
            audioTrack: audioTrack,
            temporaryDirectory: temporary,
          );
          if (generation != _generation) return [];
          return worker.process(samples, audioStart, start, end);
        },
      );
      _track = player.stream.track.listen((track) {
        if (track.audio.id != audioTrack && generation == _generation) {
          unawaited(stop());
        }
      });
      session.start();
    } on Object catch (_) {
      if (generation == _generation) _opening = null;
      if (ref.mounted && generation == _generation) {
        // Never expose native errors: they can contain authenticated media URLs.
        state = LocalCaptions(
          mode: mode,
          player: player,
          frame: const CaptionFrame(CaptionStatus.failed),
        );
      }
    }
  }
}
