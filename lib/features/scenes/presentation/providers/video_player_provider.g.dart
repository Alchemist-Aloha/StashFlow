// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_player_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlayerState)
final playerStateProvider = PlayerStateProvider._();

final class PlayerStateProvider extends $NotifierProvider<PlayerState, Scene?> {
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
  Override overrideWithValue(Scene? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Scene?>(value),
    );
  }
}

String _$playerStateHash() => r'38081e6ff5611d806dcbb2f4e590cd9da97082d4';

abstract class _$PlayerState extends $Notifier<Scene?> {
  Scene? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Scene?, Scene?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Scene?, Scene?>,
              Scene?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
