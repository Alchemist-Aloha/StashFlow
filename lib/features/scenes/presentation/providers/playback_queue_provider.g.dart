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
    extends $NotifierProvider<PlaybackQueue, List<Scene>> {
  PlaybackQueueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playbackQueueProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playbackQueueHash();

  @$internal
  @override
  PlaybackQueue create() => PlaybackQueue();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Scene> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Scene>>(value),
    );
  }
}

String _$playbackQueueHash() => r'6dc2610e550b280f4cc99f01c4586d06d14d51d1';

abstract class _$PlaybackQueue extends $Notifier<List<Scene>> {
  List<Scene> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Scene>, List<Scene>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Scene>, List<Scene>>,
              List<Scene>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
