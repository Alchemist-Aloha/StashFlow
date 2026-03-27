// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_queue_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A notifier that manages the sequence of scenes for continuous playback.
///
/// This provider is marked as `keepAlive: true` to ensure that the playback
/// sequence is preserved across navigation transitions (e.g., between
/// Grid view, TikTok view, and Scene Details).
///
/// It acts as the single source of truth for "Next" and "Previous" navigation
/// within a given context (like the main scene list).

@ProviderFor(PlaybackQueue)
final playbackQueueProvider = PlaybackQueueProvider._();

/// A notifier that manages the sequence of scenes for continuous playback.
///
/// This provider is marked as `keepAlive: true` to ensure that the playback
/// sequence is preserved across navigation transitions (e.g., between
/// Grid view, TikTok view, and Scene Details).
///
/// It acts as the single source of truth for "Next" and "Previous" navigation
/// within a given context (like the main scene list).
final class PlaybackQueueProvider
    extends $NotifierProvider<PlaybackQueue, PlaybackQueueState> {
  /// A notifier that manages the sequence of scenes for continuous playback.
  ///
  /// This provider is marked as `keepAlive: true` to ensure that the playback
  /// sequence is preserved across navigation transitions (e.g., between
  /// Grid view, TikTok view, and Scene Details).
  ///
  /// It acts as the single source of truth for "Next" and "Previous" navigation
  /// within a given context (like the main scene list).
  PlaybackQueueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playbackQueueProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playbackQueueHash();

  @$internal
  @override
  PlaybackQueue create() => PlaybackQueue();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlaybackQueueState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlaybackQueueState>(value),
    );
  }
}

String _$playbackQueueHash() => r'dbd0dcf56441b966b1843f127ae42a4efd85d7c8';

/// A notifier that manages the sequence of scenes for continuous playback.
///
/// This provider is marked as `keepAlive: true` to ensure that the playback
/// sequence is preserved across navigation transitions (e.g., between
/// Grid view, TikTok view, and Scene Details).
///
/// It acts as the single source of truth for "Next" and "Previous" navigation
/// within a given context (like the main scene list).

abstract class _$PlaybackQueue extends $Notifier<PlaybackQueueState> {
  PlaybackQueueState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PlaybackQueueState, PlaybackQueueState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlaybackQueueState, PlaybackQueueState>,
              PlaybackQueueState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
