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

String _$performerMediaHash() => r'cadf64b3827452328200f729188463d7b63e4ae1';

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

@ProviderFor(PerformerMediaGrid)
final performerMediaGridProvider = PerformerMediaGridFamily._();

final class PerformerMediaGridProvider
    extends
        $AsyncNotifierProvider<PerformerMediaGrid, List<PerformerMediaItem>> {
  PerformerMediaGridProvider._({
    required PerformerMediaGridFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'performerMediaGridProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$performerMediaGridHash();

  @override
  String toString() {
    return r'performerMediaGridProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PerformerMediaGrid create() => PerformerMediaGrid();

  @override
  bool operator ==(Object other) {
    return other is PerformerMediaGridProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$performerMediaGridHash() =>
    r'f624af83cf442aff10f90661d1539a6e161b993d';

final class PerformerMediaGridFamily extends $Family
    with
        $ClassFamilyOverride<
          PerformerMediaGrid,
          AsyncValue<List<PerformerMediaItem>>,
          List<PerformerMediaItem>,
          FutureOr<List<PerformerMediaItem>>,
          String
        > {
  PerformerMediaGridFamily._()
    : super(
        retry: null,
        name: r'performerMediaGridProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PerformerMediaGridProvider call(String performerId) =>
      PerformerMediaGridProvider._(argument: performerId, from: this);

  @override
  String toString() => r'performerMediaGridProvider';
}

abstract class _$PerformerMediaGrid
    extends $AsyncNotifier<List<PerformerMediaItem>> {
  late final _$args = ref.$arg as String;
  String get performerId => _$args;

  FutureOr<List<PerformerMediaItem>> build(String performerId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<PerformerMediaItem>>,
              List<PerformerMediaItem>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<PerformerMediaItem>>,
                List<PerformerMediaItem>
              >,
              AsyncValue<List<PerformerMediaItem>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
