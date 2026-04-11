// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_player_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A centralized notifier managing the global video player lifecycle.
///
/// This class handles:
/// - Controller initialization and disposal.
/// - Synchronization with system media controls (MediaSession).
/// - Handling transitions between scenes (Play Next).
/// - Managing UI-related playback settings (PiP, Fullscreen).

@ProviderFor(PlayerState)
final playerStateProvider = PlayerStateProvider._();

/// A centralized notifier managing the global video player lifecycle.
///
/// This class handles:
/// - Controller initialization and disposal.
/// - Synchronization with system media controls (MediaSession).
/// - Handling transitions between scenes (Play Next).
/// - Managing UI-related playback settings (PiP, Fullscreen).
final class PlayerStateProvider
    extends $NotifierProvider<PlayerState, GlobalPlayerState> {
  /// A centralized notifier managing the global video player lifecycle.
  ///
  /// This class handles:
  /// - Controller initialization and disposal.
  /// - Synchronization with system media controls (MediaSession).
  /// - Handling transitions between scenes (Play Next).
  /// - Managing UI-related playback settings (PiP, Fullscreen).
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

String _$playerStateHash() => r'3bca654c07854a730a535dae98d179d17f5f4bb2';

/// A centralized notifier managing the global video player lifecycle.
///
/// This class handles:
/// - Controller initialization and disposal.
/// - Synchronization with system media controls (MediaSession).
/// - Handling transitions between scenes (Play Next).
/// - Managing UI-related playback settings (PiP, Fullscreen).

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
