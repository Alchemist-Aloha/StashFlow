// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream_resolver.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A utility that resolves the best available video stream for a given [Scene].
///
/// Stash provides multiple ways to stream a scene:
/// 1. Direct file paths (if the client has network access to the storage).
/// 2. Scene-specific stream endpoints (transcoded or direct-from-server).
///
/// This class handles the logic of choosing between these options based on
/// user preferences and stream availability.

@ProviderFor(StreamResolver)
final streamResolverProvider = StreamResolverProvider._();

/// A utility that resolves the best available video stream for a given [Scene].
///
/// Stash provides multiple ways to stream a scene:
/// 1. Direct file paths (if the client has network access to the storage).
/// 2. Scene-specific stream endpoints (transcoded or direct-from-server).
///
/// This class handles the logic of choosing between these options based on
/// user preferences and stream availability.
final class StreamResolverProvider
    extends $NotifierProvider<StreamResolver, void> {
  /// A utility that resolves the best available video stream for a given [Scene].
  ///
  /// Stash provides multiple ways to stream a scene:
  /// 1. Direct file paths (if the client has network access to the storage).
  /// 2. Scene-specific stream endpoints (transcoded or direct-from-server).
  ///
  /// This class handles the logic of choosing between these options based on
  /// user preferences and stream availability.
  StreamResolverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streamResolverProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streamResolverHash();

  @$internal
  @override
  StreamResolver create() => StreamResolver();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$streamResolverHash() => r'306c008cf456c263abe35db8ba71fb7dc7900703';

/// A utility that resolves the best available video stream for a given [Scene].
///
/// Stash provides multiple ways to stream a scene:
/// 1. Direct file paths (if the client has network access to the storage).
/// 2. Scene-specific stream endpoints (transcoded or direct-from-server).
///
/// This class handles the logic of choosing between these options based on
/// user preferences and stream availability.

abstract class _$StreamResolver extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
