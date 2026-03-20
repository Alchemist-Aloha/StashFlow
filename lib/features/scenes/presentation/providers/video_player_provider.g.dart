// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_player_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlayerState)
final playerStateProvider = PlayerStateProvider._();

final class PlayerStateProvider
    extends $NotifierProvider<PlayerState, GlobalPlayerState> {
  PlayerStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerStateHash();

  @$internal
  @override
  PlayerState create() => PlayerState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GlobalPlayerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GlobalPlayerState>(value),
    );
  }
}

String _$playerStateHash() => r'c01897616635f171817bfda5dd73b2313c5114d1';

abstract class _$PlayerState extends $Notifier<GlobalPlayerState> {
  GlobalPlayerState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<GlobalPlayerState, GlobalPlayerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GlobalPlayerState, GlobalPlayerState>,
              GlobalPlayerState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
