// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performer_media_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(performerMedia)
final performerMediaProvider = PerformerMediaFamily._();

final class PerformerMediaProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PerformerMediaItem>>,
          List<PerformerMediaItem>,
          FutureOr<List<PerformerMediaItem>>
        >
    with
        $FutureModifier<List<PerformerMediaItem>>,
        $FutureProvider<List<PerformerMediaItem>> {
  PerformerMediaProvider._({
    required PerformerMediaFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'performerMediaProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$performerMediaHash();

  @override
  String toString() {
    return r'performerMediaProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PerformerMediaItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PerformerMediaItem>> create(Ref ref) {
    final argument = this.argument as String;
    return performerMedia(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PerformerMediaProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$performerMediaHash() => r'f224fd163fb6f639fd8e2032ae775dde2d9e3270';

final class PerformerMediaFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PerformerMediaItem>>, String> {
  PerformerMediaFamily._()
    : super(
        retry: null,
        name: r'performerMediaProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PerformerMediaProvider call(String performerId) =>
      PerformerMediaProvider._(argument: performerId, from: this);

  @override
  String toString() => r'performerMediaProvider';
}
