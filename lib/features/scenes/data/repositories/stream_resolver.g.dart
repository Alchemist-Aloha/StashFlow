// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream_resolver.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StreamResolver)
final streamResolverProvider = StreamResolverProvider._();

final class StreamResolverProvider
    extends $NotifierProvider<StreamResolver, void> {
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

String _$streamResolverHash() => r'9732deecc69071acd869906c3b26b9b3ada99fce';

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
