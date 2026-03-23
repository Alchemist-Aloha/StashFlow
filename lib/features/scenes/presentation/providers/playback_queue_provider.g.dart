// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_queue_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlaybackQueue)
final playbackQueueProvider = PlaybackQueueProvider._();

final class PlaybackQueueProvider
    extends $NotifierProvider<PlaybackQueue, PlaybackQueueState> {
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

String _$playbackQueueHash() => r'b1352e1a894c9de6323884ffee069228ee6009d9';

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
